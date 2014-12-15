From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] net: Disallow providing non zero VLAN ID for NIC
 drivers FDB add flow
Date: Mon, 15 Dec 2014 10:31:35 -0500
Message-ID: <548EFED7.7060406@mojatatu.com>
References: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com> <20141214192351.GA1850@nanopsycho.orion> <CAJ3xEMhbic5w4d0dGsTMRDoq5Vx8wqZRFpy-q+8HaeDfYciUqw@mail.gmail.com> <20141214223354.GA2035@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jiri Pirko <jiri@resnulli.us>, Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:42422 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaLOPbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 10:31:37 -0500
Received: by mail-ig0-f170.google.com with SMTP id r2so6121481igi.1
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 07:31:37 -0800 (PST)
In-Reply-To: <20141214223354.GA2035@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/14 17:33, Jiri Pirko wrote:
> Sun, Dec 14, 2014 at 09:14:27PM CET, gerlitz.or@gmail.com wrote:
>> On Sun, Dec 14, 2014 at 9:23 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Sun, Dec 14, 2014 at 05:19:05PM CET, ogerlitz@mellanox.com wrote:
>>>> The current implementations all use dev_uc_add_excl() and such whose API
>>>> doesn't support vlans, so we can't make it with NICs HW for now.
>>>>
>>>> Fixes: f6f6424ba773 ('net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del')
>>>
>>> Maybe I'm missing something, but this commit did not introduce the
>>> problem.
>>
>> This commit introduced the vid param to ndo_fdb_add and ndo_dflt_fdb_add
>> which further call the dev_uc_add APIs... so it did introduced the
>> ability to provide VID into these APIs, right? and we want to protect
>> against anyone using this ability @ this point.
>
> That is in-kernel change. Vs. usespace the patch is a no-op. If userspace
> fills up NDA_VLAN, it is ignored before the patch as well as after. No
> behaviour change, just +- cosmetics.
>

Indeed doesnt break anything, but:
I think this brings to the forefront what these dev_uc/mc addresses
are supposed to be here. I am sure there is a good reason to tie them
to the fdb API - I am just not grokking it at the moment.
The concept of a vlanid makes sense for an fdb entry. It
starts to break when you start tying in vlans - i.e i am not aware
of multicast/unicast device entries which are tied to vlans.
Maybe this is some SRIOV thing?

cheers,
jamal
