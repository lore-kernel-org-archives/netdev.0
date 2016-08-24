From: "Dan Akunis" <dan.akunis@gmail.com>
Subject: Re: [REGRESSION] Select hang with zero sized UDP packets
Date: Wed, 24 Aug 2016 11:22:09 +0300
Message-ID: <2ABF798B42E64D9C89DEB806A2E636B5@mtl.com>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com> <20160823.112515.318902967155957764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        format=flowed;
        charset="iso-8859-1";
        reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
        <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <samanthakumar@google.com>, <willemb@google.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <labbott@redhat.com>, "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160823.112515.318902967155957764.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When select wakes up on a UDP socket, user is expecting to get data. Getting 
0 from recvfrom() or whatever read function she uses, is a wrong attitude.
I agree with David.

The unit test that expects select to wake up is wrong and should be changed.

-----Original Message----- 
From: David Miller
Sent: Tuesday, August 23, 2016 9:25 PM
To: labbott@redhat.com
Cc: kuznet@ms2.inr.ac.ru ; jmorris@namei.org ; yoshfuji@linux-ipv6.org ; 
kaber@trash.net ; samanthakumar@google.com ; willemb@google.com ; 
netdev@vger.kernel.org ; linux-kernel@vger.kernel.org
Subject: Re: [REGRESSION] Select hang with zero sized UDP packets

From: Laura Abbott <labbott@redhat.com>
Date: Tue, 23 Aug 2016 10:53:26 -0700

> Fedora received a report[1] of a unit test failing on Ruby when using
> the
> 4.7 kernel. This was a test to send a zero sized UDP packet. With the
> 4.7 kernel, the test now timing out on a select instead of completing.
> The reduced ruby test is
>
>   def test_udp_recvfrom_nonblock
>     u1 = UDPSocket.new
>     u2 = UDPSocket.new
>     u1.bind("127.0.0.1", 0)
>     u2.send("", 0, u1.getsockname)
>     IO.select [u1]  # test gets stuck here
>   ensure
>     u1.close if u1
>     u2.close if u2
>   end

Well, if there is no data, should select really wake up?

I think it's valid not to. 
