From: "Karl Pickett" <karl.pickett@gmail.com>
Subject: Re: tcp_tw_recycle broken?
Date: Sat, 15 Nov 2008 10:47:10 -0500
Message-ID: <f9be06770811150747l574badc1l8d509baae4f81ac5@mail.gmail.com>
References: <f9be06770811142037v794cf4f8w7a82ab45c0f3820c@mail.gmail.com>
	 <20081115055748.GY24654@1wt.eu>
	 <f9be06770811142329x7d6dcb89vd573962970d503b3@mail.gmail.com>
	 <874p2916hb.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:8613 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbYKOPrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 10:47:11 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1802610rvb.1
        for <netdev@vger.kernel.org>; Sat, 15 Nov 2008 07:47:11 -0800 (PST)
In-Reply-To: <874p2916hb.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2008 at 8:09 AM, Andi Kleen <andi@firstfloor.org> wrote:
> "Karl Pickett" <karl.pickett@gmail.com> writes:
>>
>> May I just confirm.. is tcp_tw_reuse NOT dependent on receiving timestamps?
>
> The big problem is that both are incompatible with NAT. So if you
> ever talk to any NATed clients don't use it.
>
> -Andi
>
> --
> ak@linux.intel.com
>


Hmph.  Running the test again - after getting a little sleep -
timestamps do indeed determine if tw_reuse/recyle work.  I must not
have let all the tw buckets expire before changing my timestamp
settings last night.

Since
A. I don't want to rely on arbitrary web servers having timestamps
B. People say it breaks NAT for clients, and the settings are global only,

I will just set TCP_TIMEWAIT_LEN to 10 seconds and call it a day.
Sure would be nice if it was a tunable, so only the most heavily
loaded customers could set it...

-- 
Karl Pickett
