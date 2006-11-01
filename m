From: jamal <hadi@cyberus.ca>
Subject: Re: Network virtualization/isolation
Date: Wed, 01 Nov 2006 09:35:06 -0500
Message-ID: <1162391707.5251.78.camel@jzny2>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com>
	 <20061026085659.33b4c6dd@freekitty> <200610271134.56830.dim@openvz.org>
	 <4541CCF4.4050306@fr.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:43729 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S2992500AbWKAOfK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 09:35:10 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GfHBQ-0002nF-Vk
	for netdev@vger.kernel.org; Wed, 01 Nov 2006 09:35:12 -0500
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <4541CCF4.4050306@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-27-10 at 11:10 +0200, Daniel Lezcano wrote:

> No, it uses virtualization at layer 2 and I had already mention it 
> before (see the first email of the thread), but thank you for the email 
> thread pointer.


What would be really useful is someone takes the time and creates a
matrix of the differences between the implementations.
It seems there are quiet a few differences but without such comparison
(to which all agree to) it is hard to form an opinion without a document
of some form.
 
For one, I am puzzled by the arguements about L2 vs L3 - Is this the
host side or inside the VE?

If it is a discussion of the host side:
To me it seems it involves the classification of some packet header
arriving on a physical netdevice on the host side (irrelevant whether
they are L2 or L7) and reaching a decision to select some redirected to
virtual netdevice.
The admin (on the host) decides what packets any VE can see. 
Once within the VE, standard Linux net stack applies. The same applies
on the egress. The admin decides what packets emanating from the VE
go where.
I dont think this is a simple L2 vs L3. You need to be able to process
IP as well as Decnet[1]

If it is a discussion on the VE side, then it needs to start at the
netdevice for simplicity IMO.

Anyways without background material on the different religions it is
hard to reach a compromise - so it would be useful for someone to write
a simple (not more than 4 pages total) background on the different
approaches. For example, you could address the following:
- how each treats packets coming in at the host level
- what happens on incoming to the VE
- what happens on egress of VE
- how each treats packets departing from the host
- how each treats inter-VE communication

Then a matrix of how each requires what modifications in the network
code. Of course all players need to agree that the description is
accurate.
Is there such a document?

cheers,
jamal

[1] Since Linux has the only SMP-capable, firewall-capable Decnet
implementation - wouldnt it be fun to have it be virtualized as
well? ;->

