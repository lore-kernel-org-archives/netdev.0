From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 6/6] ethernet/broadcom: Use napi_alloc_skb instead
 of netdev_alloc_skb_ip_align
Date: Wed, 10 Dec 2014 07:16:14 -0800
Message-ID: <548863BE.302@gmail.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20> <20141210034117.2114.50589.stgit@ahduyck-vm-fedora20> <063D6719AE5E284EB5DD2968C1650D6D1CA09D86@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D1CA09DA9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	"brouer@redhat.com" <brouer@redhat.com>,
	Gary Zambrano <zambrano@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ast@plumgrid.com" <ast@plumgrid.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Alexander Duyck' <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:42667 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757407AbaLJPQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 10:16:16 -0500
Received: by mail-pd0-f180.google.com with SMTP id w10so2961862pde.11
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 07:16:16 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA09DA9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2014 01:52 AM, David Laight wrote:
> From: David Laight
>> From: Alexander Duyck
>>> This patch replaces the calls to netdev_alloc_skb_ip_align in the
>>> copybreak paths.
>> Why?
>>
>> You still want the IP header to be aligned and you also want the
>> memcpy() to be copying aligned data.
>>
>> I suspect this fails on both counts?
> Or am I confused by the naming?
>
> 	David
>

The bit you are missing is that napi_alloc_skb is always IP aligned. 
The general idea with napi_alloc_skb is that it is a cheaper way
allocate frames that are about to be passed up the stack as a NAPI or
GRO receive so the IP aligned part is a given.

- Alex
