From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: bpf filter : support for vlan tag
Date: Fri, 19 Oct 2012 11:32:10 -0700
Message-ID: <CAOxq_8NWMy2gL4QQv_e2hjHZZnFyFghmXzN5EnrXz3SRULxR6A@mail.gmail.com>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	<1350369998.3954.563.camel@edumazet-glaptop>
	<CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	<1350386917.3954.890.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <danborkmann@iogearbox.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:63752 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab2JSScK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 14:32:10 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so527290iag.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 11:32:10 -0700 (PDT)
In-Reply-To: <1350386917.3954.890.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

how about this?

On Tue, Oct 16, 2012 at 4:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> @@ -341,6 +342,12 @@ load_b:
>                 case BPF_S_ANC_CPU:
>                         A = raw_smp_processor_id();
>                         continue;
> +               case BPF_S_ANC_VLAN_TAG:
> +                       A = vlan_tx_tag_get(skb);
> +                       continue;
> +               case BPF_S_ANC_VLAN_TAG_PRESENT:
> +                       A = !!vlan_tx_tag_present(skb);
> +                       continue;
>                 case BPF_S_ANC_NLATTR: {
>                         struct nlattr *nla;


+               case BPF_S_ANC_VLAN_TAG:
+                       if (!vlan_tx_tag_present(skb)) {
+                               return 0;
+                       }
+                       A = vlan_tx_tag_get(skb);
+                       continue;
+               case BPF_S_ANC_VLAN_TAG_PRESENT :
+                       A = !! vlan_tx_tag_present(skb);
+                       continue;

Now, is there any particular reason we are not using clan_get_tag() api?

Thanks
ani
