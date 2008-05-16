From: Andy Fleming <afleming@freescale.com>
Subject: Re: Need ioctl for multiple register phy access
Date: Fri, 16 May 2008 13:05:41 -0500
Message-ID: <F926C377-5D8A-44BF-B3A0-B9A397514200@freescale.com>
References: <010200463BAAFF45926C5BFD8E21F515F525F9@cos-us-mb01.cos.agilent.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "<glenn_engel@agilent.com>" <glenn_engel@agilent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:55090 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbYEPSFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 14:05:51 -0400
In-Reply-To: <010200463BAAFF45926C5BFD8E21F515F525F9@cos-us-mb01.cos.agilent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 16, 2008, at 11:34, <glenn_engel@agilent.com> <glenn_engel@agilent.com 
 > wrote:

> Some of the newer versions of the National Phy chip have additional  
> 'pages' of registers for things like link diagnostics or ieee1588  
> control.  Some of these require multiple writes to the phy (e.g  
> write page number to reg 19, then write to one or more registers on  
> that page).  Additionally, some phy registers have depth and may  
> need multiple reads or writes as they have more than 16 bits of  
> data.  Since these operations need to be done without interruption  
> of other phy commands, the usual write one register or read one  
> register ioctl technique does not work.  Since the phy access is an  
> intimate part of the driver it would seem the logical place would be  
> to enhance the existing driver to deal with these new phy  
> capabilities.
>
> Option 1. - Use the existing SIOCGMIIREG/SIOCSMIIREG ioctl and use a  
> magic phy_id (e.g 0xffff) in the mii_ioctl_data structure to  
> indicate a multi register access request.   The data would then be  
> encoded as a variable length sequence:
>
>    <number of bytes to follow>
>    <16 bit encoded R/W, phy id, page#, register#>
>    <16 bit write value or read result>
>    <repeat in groups of two 16 bit words>
>
> Option 2 - Add a new ioctl to allow multiple register access.  The  
> format would be something like a list of 'commands' such as read  
> register R1 on page P1,  write register R2 on page P2 etc.  I see an  
> ioctl SIOCDEVPRIVATE but I also see a comment about it being removed  
> in the future.
>
> Suggestions welcome on how to address this.


Another option would be to use the PHY Lib to deal with this.  Porting  
a driver to use the PHY Lib is fairly easy, and then you would have  
the ability to lock the bus and do your writes, or to modify the  
driver for that PHY so it configures things as needed.

Andy
