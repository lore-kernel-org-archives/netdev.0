From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Internet-Draft on Port Randomisation
Date: Tue, 09 Sep 2008 16:28:30 +0200
Message-ID: <878wu1tmup.fsf@basil.nowhere.org>
References: <28fa9c5e0809082107p7a33dc4fod344fde212e1d710@mail.gmail.com>
	<48C60284.2070402@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Teo <eugeneteo@kernel.sg>, netdev@vger.kernel.org,
	Eugene Teo <eteo@redhat.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:42048 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbYIIO2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 10:28:33 -0400
In-Reply-To: <48C60284.2070402@vyatta.com> (Stephen Hemminger's message of "Mon, 08 Sep 2008 21:58:44 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen.hemminger@vyatta.com> writes:

> Eugene Teo wrote:
>> Has anyone read this Internet-Draft?
>> http://www.gont.com.ar/drafts/port-randomization/draft-ietf-tsvwg-port-randomization-02.txt
>>
>> In this memo, there are descriptions of four different ephemeral port
>> randomisation algorithms (see page 17).
>>
>> Algo #1 and #2 are simple port randomisation algorithms. Algo #3 is
>> what we have in Linux. The memo suggested algorithm #4, double-hash
>> randomisation algorithm, which is an improvement to algo #3 (see page
>> 15).
>>
>> Does anyone have any thought about the improved algorithm? Is this
>> worth implementing,
> No the added lock overhead of a global next free port array is not
> worth it. 

[haven't read the draft] But you don't necessarily need a full global
lock for such a scheme. What works too is to access global state only
ever N accesses and pre-allocate a small range per CPU. While there's
still some global overhead then, it happens significantly less. My old
alternative ipid setup algorithm worked this way.

One drawback of such a scheme today: on RT kernels the per CPU state
tends to be become a problem.

-Andi
-- 
ak@linux.intel.com
