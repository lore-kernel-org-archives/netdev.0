From: "David S. Miller" <davem@redhat.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Thu, 11 Sep 2003 13:12:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911131219.0ab8dfdd.davem@redhat.com>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
	<3F60CA6D.9090503@pobox.com>
	<3F60D0F3.8080006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F60D0F3.8080006@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2003 12:45:55 -0700
Ben Greear <greearb@candelatech.com> wrote:

> Erm, shouldn't the local machine back itself off if the various
> queues are full?  Some time back I looked through the code and it
> appeared to.  If not, I think it should.

Generic networking device queues drop when the overflow.

Whatever dev->tx_queue_len is set to, the device driver needs
to be prepared to be able to queue successfully.

Most people run into problems when they run stupid UDP applications
that send a stream of tinygrams (<~64 bytes).  The solutions are to
either fix the UDP app or restrict it's socket send buffer size.
