From: "Jan Altenberg" <jan@linutronix.de>
Subject: Re: can: c_can: TX delivery
Date: Wed, 23 Mar 2011 16:32:31 +0100
Message-ID: <ff5ade24e148af2e46832e5a64444d05.squirrel@www2.linutronix.de>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
    <20110323085340.GC346@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jan Altenberg" <jan@linutronix.de>, bhupesh.sharma@st.com,
	wg@grandegger.com, b.spranger@linutronix.de, netdev@vger.kernel.org
To: "Kurt Van Dijck" <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48443 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933043Ab1CWPcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 11:32:35 -0400
In-Reply-To: <20110323085340.GC346@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> I split your 2 questions in 2 replies.

Thanks :)

> not sure if I made my point.  Note that this will eliminate the need
> for explicit wrap-around.  It's done implicitely.

Hmmm, I double-checked the datasheet, which gives the following statement:
"The receive/transmit priority for the Message Objects is attached to
the message number.  Message Object 1 has the highest priority, while
Message Object 32 has the lowest priority. If more than one
transmission request is pending, they are serviced due to the priority
of the corresponding Message Object."

So, we shouldn't run into the scenario I described in my previous mail
and the existing implementation should be OK, right?!  I'm quite sure
I've seen a situation where msg_obj 17 "seemed" to be pending, while
msg_obj 18 and 19 already have been transmitted. But in that case, I
enabled ONESHOT for the can interface, which enables the DA mode
(automatic
retransmission is disabled). The errata sheet for c_can covers that
mode. There's a problem with "Concurrent transmission requests" and I'm
quite sure my test-case hit that problem.

I'm quite new to Bosch's c_can, so maybe Bhupesh can give some feedback
(or beat me for causing some confusion ;-)).

Sorry for the confusion!
        Jan


