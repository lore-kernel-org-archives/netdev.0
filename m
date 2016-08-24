From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [REGRESSION] Select hang with zero sized UDP packets
Date: Wed, 24 Aug 2016 14:42:46 +0100
Message-ID: <20160824144246.5a61254c@lxorguk.ukuu.org.uk>
References: <08d225a8-e98f-c0c6-271d-acc2584347fc@redhat.com>
        <20160823.112515.318902967155957764.davem@davemloft.net>
        <2ABF798B42E64D9C89DEB806A2E636B5@mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <labbott@redhat.com>, "David Miller" <davem@davemloft.net>,
        <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
        <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <samanthakumar@google.com>, <willemb@google.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Dan Akunis" <dan.akunis@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2ABF798B42E64D9C89DEB806A2E636B5@mtl.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Aug 2016 11:22:09 +0300
"Dan Akunis" <dan.akunis@gmail.com> wrote:

> When select wakes up on a UDP socket, user is expecting to get data. Getting 
> 0 from recvfrom() or whatever read function she uses, is a wrong attitude.
> I agree with David.
> 
> The unit test that expects select to wake up is wrong and should be changed.

The unit test is correct.

The behaviour of a 0 byte frame is actually well established and a 0 byte
data frame is a meaningful message is several protocols. It is distinct
from no pending data because that would report EWOULDBLOCK. It's more fun
with regard to EOF but UDP has no EOF semantics. If you want to
understand how to handle zero length datagrams in a connection oriented
protocol the old DECnet documentation covers it in all its pain 8)

Alan
