From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION] Select hang with zero sized UDP packets
Date: Wed, 24 Aug 2016 06:02:15 -0700
Message-ID: <1472043735.14381.69.camel@edumazet-glaptop3.roam.corp.google.com>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
         <20160823.112515.318902967155957764.davem@davemloft.net>
         <2ABF798B42E64D9C89DEB806A2E636B5@mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: labbott@redhat.com, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, samanthakumar@google.com, willemb@google.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Akunis <dan.akunis@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2ABF798B42E64D9C89DEB806A2E636B5@mtl.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-24 at 11:22 +0300, Dan Akunis wrote:
> When select wakes up on a UDP socket, user is expecting to get data. Getting 
> 0 from recvfrom() or whatever read function she uses, is a wrong attitude.
> I agree with David.
> 
> The unit test that expects select to wake up is wrong and should be changed.
> 

Please do not top post on netdev mailing list.

Program is fine and wont be changed to work around a kernel bug.

We definitely can send and receive UDP messages with 0 payload.

So select() should unblock when one such frame is received, otherwise
you could fill up the receive queue with a lot of frames like that and
when SO_RCVBUF limit is reached, block future messages.

UDP is a datagram protocol.

Bug fix is merged :
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=e83c6744e81abc93a20d0eb3b7f504a176a6126a
