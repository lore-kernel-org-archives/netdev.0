From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] diag: fix netlink API attributes
Date: Fri, 29 Nov 2013 09:28:44 +0100
Message-ID: <5298503C.6080100@6wind.com>
References: <1385647039-1547-1-git-send-email-nicolas.dichtel@6wind.com> <20131128163816.GA32047@casper.infradead.org> <52977F44.6070002@6wind.com> <20131128221916.GB4100@casper.infradead.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Samuel.gauthier@6wind.com" <Samuel.gauthier@6wind.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:45588 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab3K2I2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 03:28:47 -0500
Received: by mail-wi0-f177.google.com with SMTP id cc10so1737671wib.16
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 00:28:46 -0800 (PST)
In-Reply-To: <20131128221916.GB4100@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/11/2013 23:19, Thomas Graf a =E9crit :
> On 11/28/13 at 06:37pm, Nicolas Dichtel wrote:
>> Le 28/11/2013 17:38, Thomas Graf a =E9crit :
>>> On 11/28/13 at 02:57pm, Nicolas Dichtel wrote:
>>>> The first netlink attribute (value 0) must always be defined as no=
ne/unspec.
>>>> This is correctly done in inet_diag.h, but other diag interfaces a=
re broken.
>>>>
>>>> Libraries like libnl skip this kind of attributes, thus it's never=
 reported to
>>>> the application.
>>>>
>>>> CC: Thomas Graf <tgraf@suug.ch>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>
>>> First of all, thanks for the notification Nicolas. I'll fix libnl t=
o
>>> pass through these attributes.
>> Fine :)
>> Thank you!
>
> Fixed in:
>
> commit 6a8d90f5fec48b6e376ff29ccf3e0c620a41e758
> Author: Thomas Graf <tgraf@suug.ch>
> Date:   Thu Nov 28 23:14:38 2013 +0100
>
>      attr: Allow attribute type 0
>
>      {netlink,packet,unix}_diag use attribute type 0 for valid
>      attributes. The value was reserved and usage was prohibited
>      by the protocol but we can't undo the breakge.
>
>      Make libnl accept attribute type 0 to allow parsing these
>      attributes.
>
>      Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>      Signed-off-by: Thomas Graf <tgraf@suug.ch>
I think the following patch is also needed (not based on HEAD):

 From 8aa4397d43fbd34deea9ed11677c04b460895f15 Mon Sep 17 00:00:00 2001
=46rom: Samuel Gauthier <samuel.gauthier@6wind.com>
Date: Fri, 29 Nov 2013 09:15:34 +0100
Subject: [PATCH] attr: Allow attribute type 0 parsing

The commit 6a8d90f5fec4 "attr: Allow attribute type 0" intended to
allow the parsing of {netlink,packet,unix}_diag, even if they are
using type 0 for valid attributes.

It lacked this part in nla_parse.

Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
---
  lib/attr.c | 4 ----
  1 file changed, 4 deletions(-)

diff --git a/lib/attr.c b/lib/attr.c
index 535f10c..1e2d57f 100644
--- a/lib/attr.c
+++ b/lib/attr.c
@@ -250,10 +250,6 @@ int nla_parse(struct nlattr *tb[], int maxtype, st=
ruct=20
nlattr *head, int len,
  	nla_for_each_attr(nla, head, len, rem) {
  		int type =3D nla_type(nla);

-		/* Padding attributes */
-		if (type =3D=3D 0)
-			continue;
-
  		if (type > maxtype)
  			continue;

--=20
1.8.0
