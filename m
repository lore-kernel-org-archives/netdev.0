From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv4 net-next 2/3] ipv4: Use binary search to choose tcp
 PMTU probe_size
Date: Thu, 05 Mar 2015 10:36:54 +0800
Message-ID: <54F7C146.603@gmail.com>
References: <1425374361-21047-1-git-send-email-fan.du@intel.com> <1425374361-21047-3-git-send-email-fan.du@intel.com> <CABrhC0k3YgvcXdx1aVzVfsgnD0FoGHaqOuqk8fUQiZhAmyVkPg@mail.gmail.com> <CABrhC0kTmdv7TJUFo88HjGgzLmm1p4_XRnuQZUoaOGh8DwmhVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38461 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106AbbCEClz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 21:41:55 -0500
Received: by pdbfl12 with SMTP id fl12so31255071pdb.5
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 18:41:54 -0800 (PST)
In-Reply-To: <CABrhC0kTmdv7TJUFo88HjGgzLmm1p4_XRnuQZUoaOGh8DwmhVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8804=E6=97=A5 21:39, John Heffner =E5=86=
=99=E9=81=93:
>> >I suspect there's plenty of room for further improvement in the
>> >probing heuristic, but this seems like a reasonable improvement.
>> >
>> >Acked-by: John Heffner<johnwheffner@gmail.com>
> Actually, one final suggestion here.  The cost of a failed probe is
> much higher than a successful probe.  I'd suggest still bounding the
> probe segment size to no more than 2*cur_mss.  (Think of a common cas=
e
> where mss_clamp =3D 9000 - headers, but the actual path MTU =3D 1500.=
)

huh...
Are you serious about clamping probe size to no more than 2*current_mss=
?
What about the opposite scenario where path MTU enlarges, e.g., current=
_mss
is nearing search_low?

I will make next version incorporating:
a. Update ip-sysctl.txt
b. Zero probe_size before reset search_low/high


>    -John
