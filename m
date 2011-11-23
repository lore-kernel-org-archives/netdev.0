From: =?UTF-8?B?RGF2aWQgVMOkaHQ=?= <dave.taht@gmail.com>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 23 Nov 2011 14:13:33 +0100
Message-ID: <4ECCF17D.5020509@gmail.com>
References: <20111123075433.GA7928@gondor.apana.org.au>  <1322035942.1298.56.camel@edumazet-laptop> <1322052463.2039.135.camel@mojatatu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090005030105050700080001"
Cc: jamal <hadi@cyberus.ca>, Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org, dev@openvswitch.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46313 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122Ab1KWNNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 08:13:39 -0500
Received: by vcbfk14 with SMTP id fk14so273017vcb.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 05:13:39 -0800 (PST)
In-Reply-To: <1322052463.2039.135.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090005030105050700080001
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 11/23/2011 01:47 PM, jamal wrote:
> On Wed, 2011-11-23 at 09:12 +0100, Eric Dumazet wrote:
>
>> I had no time to look at OVS, but current tc model is not scalable,
>> everything is performed under a queue lock.
>> Maybe its time to redesign a new model, based on modern techniques.
> Making the enqueur/dequeuer lockless would be a big win. What happened
> to your idea of ring buffer?

It's not so much 'modern tecniques', as modern environments.

High on my list would be a way to more easily expose QoS and AQM
features in the hardware all the way up the stack.

I'd like the hardware to be able to express 'I have FQ', or 'I have red',
much like we express many other features in ethtool, only abstractly 
enough so that a qdisc setup can be made generic.

> What other hot areas do you see? It used to be ingress/egress share
> the qdisc lock - but that is now gone.
I find the mapping from hardware queues to any sort of complex software 
queuing scheme hard to conceptualize. Also, as structured, tc cannot be 
easily applied to wireless APs.

>
>> By the way, we seriously lack good documentation on tc, not counting
>> many features. Code might be there, but without documenation, working
>> samples, who can use it ?
I find tc's concepts incredibly difficult to use effectively. They start 
with the presumption that what you are working with is a 1998 point to 
point link and get harder from there. That said I think I've almost 
managed to bend it to my will of late...

(this email written under the influence of Byte Queue Limits + QFQ + 
RED, on ethernet)

>>
>> Take a look at last cls_flow extension, and try to use it on a real
>> setup, you'll find its almost not possible...
>
> There's no tc-central.org unlike the nice effort the netfilter guys have
> put over the years. Documentation is there - sometimes a little too much
> with differing "opinions" (lartc that Herbert pointed to is a good
> starting point); but googling also helps.
> Unfortunately, sometimes the people who understand stuff have no
> motivation to do docs.
After burning the last several months getting good enough at the tc layer
to do stuff in it, I would certainly like to have a place to put 
documentation,
and also easily update what already exists.

If it helps any I could offer a redmine instance on bufferbloat.net for 
this.
redmine has bug tracking and a wiki...

It would be nice also if the iproute2 code contained more working examples,
and man pages.

It's a ton of doc work, but I'd be willing to do some of it.

>
> cheers,
> jamal
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Dave Täht


--------------090005030105050700080001
Content-Type: text/x-vcard; charset=utf-8;
 name="dave_taht.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dave_taht.vcf"

YmVnaW46dmNhcmQNCmZuO3F1b3RlZC1wcmludGFibGU6RGF2ZSBUPUMzPUE0aHQNCm47cXVv
dGVkLXByaW50YWJsZTpUPUMzPUE0aHQ7RGF2ZQ0KZW1haWw7aW50ZXJuZXQ6ZGF2ZS50YWh0
QGdtYWlsLmNvbQ0KdGVsO2hvbWU6MS0yMzktODI5LTU2MDgNCnRlbDtjZWxsOjA2Mzg2NDUz
NzQNCngtbW96aWxsYS1odG1sOkZBTFNFDQp2ZXJzaW9uOjIuMQ0KZW5kOnZjYXJkDQoNCg==
--------------090005030105050700080001--
