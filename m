From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 2/2] ip_tunnel: Add fallback tunnels to the hash lists
Date: Fri, 27 Sep 2013 19:40:34 -0700
Message-ID: <CALnjE+oKZLj8vdDsgUhg_3nB7Ypicu-tOm_h3xhjnEjbkwLirA@mail.gmail.com>
References: <20130925055418.GV7660@secunet.com>
	<20130925055519.GW7660@secunet.com>
	<CALnjE+rrm3Vzov4sUjBfEKHwzRb6MfTRhkA_B96yuNGpgFgiCg@mail.gmail.com>
	<20130926081344.GA7660@secunet.com>
	<CALnjE+pu6CEwB+p3TNH56N09Cwabr9QbaKotKiwbfyLvZUsSpA@mail.gmail.com>
	<20130927075654.GE7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:41204 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754204Ab3I1Ckf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 22:40:35 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2317338qcz.28
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 19:40:34 -0700 (PDT)
In-Reply-To: <20130927075654.GE7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 12:56 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Sep 26, 2013 at 11:24:07AM -0700, Pravin Shelar wrote:
>> On Thu, Sep 26, 2013 at 1:13 AM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> > On Wed, Sep 25, 2013 at 09:03:11AM -0700, Pravin Shelar wrote:
>> >> fallback tunnel s not required to be in hash table, Its is returned if
>> >> none of hashed tunnels are matched, ref ip_tunnel_lookup().
>> >> Can you post command to reproduce this issue?
>> >>
>> >
>> > Something like
>> >
>> > ip tunnel change tunl0 mode ipip remote 0.0.0.0 local 0.0.0.0 ttl 0 tos 1
>> >
>> > worked until v3.9 and stopped working with v3.10.
>>
>> OK, I see the bug, tunnel exact match lookup does not check fb tunnel.
>> There are two options.
>> 1. Fix ip_tunnel_find() to check for fb tunnel.
>> 2. Add fb tunnel to hash table, which is what ur patch does.
>> I think your patch is better solution as it get rid of special case.
>> But patch is not complete. It needs to remove fb tunnel checks on
>> netdev unregister.
>
> It looks like this is another bug that requires an additional patch.
> We add the fallback tunnel to the unregister list when we iterate over
> all netdevices in the namespace at the beginning of ip_tunnel_destroy()
> and then again explicitly at the end of ip_tunnel_destroy().

right.
And if the special case is removed, code will become simple.
