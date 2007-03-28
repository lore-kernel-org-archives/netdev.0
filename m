From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Subject: Re: RFC: Established connections hash function
Date: Tue, 27 Mar 2007 22:01:38 -0700
Message-ID: <EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <p73lkhi6aj7.fsf@bingen.suse.de>
Reply-To: nikb@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <ak@suse.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:3501 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbXC1FC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 01:02:26 -0400
Received: from XEON by webmaster.com
	(Cipher TLSv1:RC4-MD5:128) (MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50001463230.msg
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 22:01:53 -0800
In-Reply-To: <p73lkhi6aj7.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Andi Kleen" (ak@suse.de) wrote:

> To truly defend against this you would likely need a cryptographic
> hash, which would be likely too slow.

    I do not think that a cryptographically secure hash is necessary for 
this. Using a better hash function (i.e. one which does a good job of 
throroughly mixing the input bits, as jenkins does), is sufficient when 
combined with a secret per-boot salt, something which is easily demonstrable 
by test runs.


> If it's a real problem the better fix would be to switch to some
> kind of balanced tree (like Evgeniy is proposing) .

    I don't have any special attachment to the Jenkins hash, or to a hash 
table even. So, _yes_, by all means if a better solution is available let us 
use it and I'll be the first to cheer. But I don't know if Evgeniy's work is 
ready for prime time, and I consider plugging in an improved hash function 
to be an acceptable solution in the meantime.


> But I think it can be mostly ignored.

    With all due respect, it cannot. An attacker with a small-sized botnet 
(which is ~250 hosts) can create chains that contain well in excess of 3000 
items. A big botnet (and there exist botnets with well over 5000 machines in 
them) can bring a system to its knees. You may not have gotten bitten by 
this, but others, including myself and Eric Dumazet have. And I believe that 
David Miller agrees, although I do not want to put words in his mouth -- or 
his keyboard, as the case may be.

    What this boils down to is, yes, we can keep patching our own kernels to 
use tagged jenkins hashing if this affects us, waiting for something better 
to come along. But isn't it more reasonable to add this into the kernel, at 
least as a non-default compile time option, and allow administrators to 
decide whether this is something they want to use?

    -n


