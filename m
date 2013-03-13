From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: AW: Trying to implement secondary loopback
Date: Wed, 13 Mar 2013 14:21:44 -0700
Message-ID: <878v5r9es7.fsf@xmission.com>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
	<87r4jjav00.fsf@xmission.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"edumazet\@google.com" <edumazet@google.com>,
	"herbert\@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: "Martitz\, Thomas" <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56896 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933237Ab3CMVWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 17:22:08 -0400
In-Reply-To: <3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de> (Thomas
	Martitz's message of "Wed, 13 Mar 2013 21:07:18 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de> writes:

>> Von: Eric W. Biederman [ebiederm@xmission.com]
>>
>> The easy solution is to setup two network namespaces and two nics.
>> And transmit data from one network namespace to another, through your
>> nics.

>
> That sounds a lot more involed than using loopback to send data back
> to the same process. And I guess just calling netif_rx() in the xmit()
> function wouldn't be sufficient either? Also I wouldn't know how to do
> that as I'm not yet very familiar with network namespaces (but that
> can clearly get fixed).

It may sound involved but it is just a few lines of code to set up.

ip netns add ns1
ip netns add ns2
ip link set nic1 netns ns1
ip link set nic2 netns ns2

int main(int argc, char **argv)
{
        int netfd1, netfd2;
        int sk1, sk2;
	netfd1 = open(/var/run/netns/nic1);
	netfd2 = open(/var/run/netns/nic2);

	setns(netfd1, 0);
	sk1 = socket(...);

        setns(netfd2, 0);
        sk2 = socket(...);

        /* test test test */
}

And what is partidcularly interesting is that all of this works with
your drivers normal code paths without any kernel hacks.

Eric
