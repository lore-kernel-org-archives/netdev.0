From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Fw: [Bug 75571] New: using tc action mirred results BUG at net/core/skbuff.c:119
Date: Thu, 08 May 2014 06:13:43 -0400
Message-ID: <536B58D7.2070009@mojatatu.com>
References: <20140506081628.1626ff94@nehalam.linuxnetplumber.net> <CAHA+R7NX639wxkvvrqP=ogeiAwDeJYDnFp_z_VqB3yqh8KLjFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, d77190@mail.ru
To: Cong Wang <cwang@twopensource.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36430 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbaEHKNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 06:13:55 -0400
Received: by mail-ig0-f169.google.com with SMTP id hl10so656525igb.2
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 03:13:55 -0700 (PDT)
In-Reply-To: <CAHA+R7NX639wxkvvrqP=ogeiAwDeJYDnFp_z_VqB3yqh8KLjFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

Sorry for the latency - on travel mode.

On 05/06/14 18:30, Cong Wang wrote:
> On Tue, May 6, 2014 at 8:16 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:

>
> Hmm, looks like we pushed wrong header size here. tcf_mirred_init()
> checks if we could push hard header by checking the type of the target device,
> while in tcf_mirred() we push the ->hard_header_len of the source device
> where this skb is received. I am not sure at all.
>
> Jamal, does the following patch make any sense for you?
>

Dont feel like that patch would help. Scratching my head....
One way to tell is to: ifconfig down the source (which seems like tunnel
device) and install all the rules then last step is ifconfig first ifb,
then the tunnel device. And if it works with current kernel patch is not
needed. It feels like some race condition between installing
rule and using it i.e rule gets installed and when still trying to
advertise to user space, a packet arrives and starts using it.
If the above works - then the question to d77190@mail.ru is what kernel
this is and when did this last work as installed?

[My gut feeling is it may have something to do with the rcu changes
perhaps - but not sure.]

cheers,
jamal
