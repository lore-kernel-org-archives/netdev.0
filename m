From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: Reduce conntrack count in nf_conntrack_free()
Date: Tue, 24 Mar 2009 14:38:48 +0100
Message-ID: <49C8E268.6090507@trash.net>
References: <OF1FEA88FD.D6B88765-ONC1257582.003A487F-C1257582.003ACE3A@transmode.se> <49C77D71.8090709@trash.net> <OF8A05682D.BA831A09-ONC1257582.0043892E-C1257582.004440BD@transmode.se> <49C780AD.70704@trash.net> <OF20814141.D78C9170-ONC1257582.0060B64A-C1257582.00614FDC@transmode.se> <49C7CB9B.1040409@trash.net> <OFBD3D31D8.7AD81126-ONC1257583.002C5C2B-C1257583.002DFF13@transmode.se> <49C8A415.1090606@cosmosbay.com> <OF9168DCC3.5E31F8E4-ONC1257583.003B48CC-C1257583.003C0A5E@transmode.se> <49C8CCF4.5050104@cosmosbay.com> <49C8D13D.10307@cosmosbay.com> <49C8D58A.6060401@trash.net> <49C8E0D3.1010202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34123 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbZCXNi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 09:38:58 -0400
In-Reply-To: <49C8E0D3.1010202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>>> I forgot to say this is what we do for 'struct file' freeing as wel=
l. We
>>> decrement nr_files in file_free(), not in file_free_rcu()
>>
>> While temporarily exceeding the limit by up to 10000 entries is
>> quite a lot, I guess the important thing is that it can't grow
>> unbounded, so I think this patch is fine.
>>
>=20
> Maybe we could use SLAB_DESTROY_BY_RCU thing and no more call_rcu() q=
ueueing
> problem. That would better use CPU caches as well...

I'm not sure I understand the rules correctly, but we'd still
have to wait for the grace period before an object can be reused,
no?



