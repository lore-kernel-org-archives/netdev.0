From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: Network QoS support in applications
Date: Thu, 11 Mar 2010 12:21:11 -0700
Message-ID: <4B9942A7.40205@redfish-solutions.com>
References: <877hr5nkx0.fsf@purkki.valot.fi>	<20100126.041610.226004766.davem@davemloft.net>	<87wrz5m3cd.fsf@purkki.valot.fi>	<20100126.050645.184040277.davem@davemloft.net> <87my01m0zm.fsf@purkki.valot.fi> <4B5EF5DF.2070005@lemonia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kalle.valo@iki.fi>, David Miller <davem@davemloft.net>,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Dunc <dunc@lemonia.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:32886 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756338Ab0CKTZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 14:25:30 -0500
In-Reply-To: <4B5EF5DF.2070005@lemonia.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/26/2010 07:02 AM, Dunc wrote:
>   
>> And you are perfectly right, as always. My choise of using the word
>> "universal" was bad. With word "universal" I meant to use same network
>> QoS API with different network technologies: ethernet, wi-fi,
>> bluetooth etc.
>>
>> But we don't need to solve everything in one go, instead we can make
>> small steps. The first step is to start pushing applications to
>> classify their streams. That's the enabler to get some sort of QoS
>> support, at least to inside kernel and to the next hop. With luck, in
>> future it might get more widely used.
>>
>> I was hoping to base the classification on some standard, but there
>> doesn't really seem to be one which would specify a complete solution.
>> But that's ok, we can always create a de facto standard :)
>>
>> I'm curious how other operation systems handle this? Or is it a
>> similar situation, nobody just doesn't use QoS for anything?
>>
>>     
> If applications set the QoS values, the who's to stop someone (for
> example) writing a bittorrent client that marks all packets for the
> highest priority as if they were VoIP or something? At this point all
> the good work done in the applications is useless and the network admin
> is going to have to not trust the QoS values and then attempt to
> classify traffic by themselves, so it was all a waste of time.
>
> It's probably better to just always leave it up to the network devices IMHO.
>
> Cheers,
>
> Dunc
>
>   

I disagree.

Some protocols are *very* hard to classify without looking into the
application layer, which I have no interest in having network devices do
(especially since in a multipath environment, they might not even see
the entire flow).

RTP, FTP-DATA, and TFTP are all very hard to classify because they don't
use fixed port numbers.

And even if you identify RTP, you still don't know if it's voice or
video since that is signaled out-of-band.

And yes, there will always be misbehaving users.  They are a fact of
life.  That doesn't mean we should lobotomize the network.  We don't
have an authentication mechanism on ICMP Redirects or Source-Quench, for
instance.  Nor is ARP authenticated.

BTW:  Why not have Linux do DSCP/CS to 802.1p priority mapping on
Ethernet drivers "out-of-the-box", regardless of whatever 802.1p tagging
is actually being used or not (i.e. make it implied on the sending
end-system).

-Philip


