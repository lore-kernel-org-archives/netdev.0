From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: r8a7790: Handle the RFE (Receive FIFO overflow
 Error) interrupt
Date: Thu, 12 Sep 2013 23:45:05 +0400
Message-ID: <523219C1.1020300@cogentembedded.com>
References: <1375142928-17769-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <51F7CADE.5070801@cogentembedded.com> <4760883.hI1JN8gopV@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
	Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4760883.hI1JN8gopV@avalon>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/30/2013 06:20 PM, Laurent Pinchart wrote:

>>> The RFE interrupt is enabled for the r8a7790 but isn't handled,
>>> resulting in the interrupts core noticing unhandled interrupts, and
>>> eventually disabling the ethernet IRQ.

>>> Fix it by adding RFE to the bitmask of error interrupts to be handled
>>> for r8a7790.

>> So, Simon hasn't synced his patch to my late bug fix in 3.10... Did this
>> patch help you with your NFS boot issue, Laurent?

> Yes, it fixes the "disabling interrupt, nobody cared" problem. I still have
> intermittent NFS issues, but at least I can now boot.

    Looks like the reason for them is the same I had to fix up for the BOCK-W: 
the bouncing LINK signal. The PHY used is the same as on BOCK-W, however, its 
LED seems to be configured differently: for LINK and ACTIVE LEDs, this is 
non-default PHY configuration which AFAIK gets reset to default when the PHY 
gets reset. What I saw when I added orintk() for the interrupt enable/mask 
tracing was the LINK signal behaving normally at first but after some time ECI 
(M-Port in the manuals) interrupts started to behave the way well known from 
BOCK-W, i.e. bouncing on and off after each packet; I was also getting endless 
RFE (Rx FIFO overflow) interrupts and NFS was unable to mount at all in this 
traced mode. The fix was the same as for BOCK-W: to set 'no_ether_link' field 
of the platfrom data to 1. After that I've no more seen NFS timeouts and RFE 
interrupts. I'm going to continue testing but thought I let everybody know of 
my currct findings and the remedy for the NFS issue.

WBR, Sergei

