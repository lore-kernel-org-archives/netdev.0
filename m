From: <glenn_engel@agilent.com>
Subject: Need ioctl for multiple register phy access
Date: Fri, 16 May 2008 10:34:35 -0600
Message-ID: <010200463BAAFF45926C5BFD8E21F515F525F9@cos-us-mb01.cos.agilent.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aglcosbs05.cos.agilent.com ([192.25.218.36]:47469 "EHLO
	aglsgpbs05.sgp.agilent.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757621AbYEPQfY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 12:35:24 -0400
Received: from mppd (localhost.localdomain [127.0.0.1])
	by aglsgpbs05.sgp.agilent.com (Postfix) with ESMTP id 20939740A7
	for <netdev@vger.kernel.org>; Fri, 16 May 2008 16:35:23 +0000 (GMT)
Received: from cos-us-bh01.cos.agilent.com (cos-us-bh01.cos.agilent.com [130.29.152.243])
	by aglsgpbs05.sgp.agilent.com (Postfix) with ESMTP id 1D7057409E
	for <netdev@vger.kernel.org>; Fri, 16 May 2008 16:35:23 +0000 (GMT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the newer versions of the National Phy chip have additional 'pages' of registers for things like link diagnostics or ieee1588 control.  Some of these require multiple writes to the phy (e.g write page number to reg 19, then write to one or more registers on that page).  Additionally, some phy registers have depth and may need multiple reads or writes as they have more than 16 bits of data.  Since these operations need to be done without interruption of other phy commands, the usual write one register or read one register ioctl technique does not work.  Since the phy access is an intimate part of the driver it would seem the logical place would be to enhance the existing driver to deal with these new phy capabilities.

Option 1. - Use the existing SIOCGMIIREG/SIOCSMIIREG ioctl and use a magic phy_id (e.g 0xffff) in the mii_ioctl_data structure to indicate a multi register access request.   The data would then be encoded as a variable length sequence:

    <number of bytes to follow>
    <16 bit encoded R/W, phy id, page#, register#>
    <16 bit write value or read result>
    <repeat in groups of two 16 bit words>

Option 2 - Add a new ioctl to allow multiple register access.  The format would be something like a list of 'commands' such as read register R1 on page P1,  write register R2 on page P2 etc.  I see an ioctl SIOCDEVPRIVATE but I also see a comment about it being removed in the future.

Suggestions welcome on how to address this.

Thanks,

--
Glenn

