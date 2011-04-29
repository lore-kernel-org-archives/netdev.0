From: John Lumby <johnlumby@hotmail.com>
Subject: Re: Is 802.3ad mode in bonding useful ?
Date: Fri, 29 Apr 2011 10:04:02 -0400
Message-ID: <4DBAC552.507@hotmail.com>
References: <4DB9185E.4050103@gmail.com> <20110428122102.GB4165@hmsreliant.think-freely.org> <4DBA2DDC.80502@gmail.com> <20110429104342.GA22387@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: WeipingPan <panweiping3@gmail.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from toip4.srvr.bell.ca ([209.226.175.87]:30533 "EHLO
	toip4.srvr.bell.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757825Ab1D2OET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 10:04:19 -0400
In-Reply-To: <20110429104342.GA22387@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/11 06:43, Neil Horman wrote:
> On Fri, Apr 29, 2011 at 11:17:48AM +0800, WeipingPan wrote:
>> On 04/28/2011 08:21 PM, Neil Horman wrote:
>>> On Thu, Apr 28, 2011 at 03:33:50PM +0800, WeipingPan wrote:
>>>> Hi, all,
>>>>
>>>> 802.3ad mode in bonding implements 802.3ad standard.
>>>>
>>>> I am just wondering  802.3ad mode is useful,
>>>> since  bonding has many modes like balance-rr, active-backup, etc.
>>>>
>>> Yes, of course its usefull.  For switches which support 802.3ad, this mode
>>> allows for both peers to understand that the links in the bond are acting as an
>>> aggregate, which makes it easier to prevent things like inadvertently looped
>>> back frames, for which the other modes have to have all sorts of hacks to
>>> prevent.


I believe another use for 802.3ad is to monitor the aggregation 
"actively"  (by sending special LACP packets) and to detect any kind of 
failure of the other end of one of the slaves more rapidly (than if 
relying on something like carrier detect).     This may improve 
availability,  although that depends on the specific network topology 
and capabilities in the switch(es).    There is information on this in 
Documentation/networking/bonding.txt.


>> What is looped back frames here ?
> In this case they are frames that get received by the bond, which the bond
> itself sent.  In modes where more than one slave is active, and in which the
> switch has no additional knoweldge of the aggregate (e.g. round robin mode), the
> bond can send a frame on one slave, which the switch may broadcast to all ports,


Isn't this (broadcasting or repeating on all ports other than incoming) 
more associated with simple hubs rather than switches?     I would think 
any switch with layer 2 capability does not do that (does it?)

> causing the frame just sent by the bond to then get received on another slave.
>
>

