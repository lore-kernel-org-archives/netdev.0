From: Mark Huth <mhuth@mvista.com>
Subject: Re: netpoll question
Date: Wed, 28 Mar 2007 16:28:59 -0700
Message-ID: <460AFA3B.6090009@mvista.com>
References: <1175119380.28767.4.camel@stevo-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:24493 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933847AbXC1X3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 19:29:00 -0400
In-Reply-To: <1175119380.28767.4.camel@stevo-laptop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> Hey all,
>
> I have netpoll question.  How does netpoll work with MSI/X, NAPI, and
> nics that setup multiple RSS style receive queues for a single port?
> >From what I can tell, if you're doing something like netdump using
> netpoll for IO, then you might never process incoming packets that get
> posted to the rx queues not associated with the main netdevice structure
> because netpoll only calls the poll() function for the main netdev
> struct.  Not the dummy netdevs setup for multiple rx queues.  
>
> Is this the case or am I confused?
>
> Thanks,
>
>
> Steve
You are correct.  Netpoll needs a bit of work, especially on the receive 
side, for multi-queue and some other possible problems related to taking 
locks when the system is frozen.  If I get some time soon, I'm going to 
propose an overhaul to address some of these issues that show up in the 
kgdboe and netdump cases.

Mark Huth
