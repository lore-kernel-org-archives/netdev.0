From: B Viswanath <marichika4@gmail.com>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress local mac
 install for all vlans
Date: Wed, 26 Aug 2015 11:40:27 +0530
Message-ID: <CAN+pFwJKFeQJw_4mPEH5_WmHdBUn75FL+-Cq=YaR+FR-+cRfEw@mail.gmail.com>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
	<20150825.194222.390859854071446877.davem@davemloft.net>
	<E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	toshiaki.makita1@gmail.com,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org, wkok@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34484 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507AbbHZGK2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 02:10:28 -0400
Received: by iodb91 with SMTP id b91so7090994iod.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 23:10:27 -0700 (PDT)
In-Reply-To: <E065D3DC-6CBC-4625-8800-5133E21C5483@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> I'd rather we fix the essence of the scalability problem than add
>> more spaghetti code to the various bridge paths.
>>
>> Can we make the fdb entries smaller?
>>
>> Can we enhance how we store such local entries such that they live i=
n
>> a compact datastructure?  Perhaps the FDB can consist of a very dens=
e
>> lookup mechanism for local stuff sitting alongside the current table=
=2E
>
> Certainly, that should be done and I will look into it, but the essen=
ce of this patch
> is a bit different. The problem here is not the size of the fdb entri=
es, it=E2=80=99s more the
> number of them - having 96000 entries (even if they were 1 byte ones)=
 is just way
> too much especially when the fdb hash size is small and static. We co=
uld work on making
> it dynamic though, but still these type of local entries per vlan per=
 port can easily be avoided
> with this option.
>

I was wondering if it is possible to assign a vlan bitmap for the FDB
entry, instead of replicating the entry for each vlan. ( I believe
Roopa has done something similar, but not so sure). This means that
the number of FDB entries remain static for any number of vlans.

I guess its more complicated than it sounds, but just wanted to know
if its feasible at all.

Thanks
Vissu

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
