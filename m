From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tg3 intr masking update
Date: Sat, 21 Dec 2002 15:38:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E04D130.8040504@pobox.com>
References: <3E04CFBE.2060909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manish Lachwani <manish@Zambeel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3E04CFBE.2060909@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Additional note about this change,

The NAPI docs mention specific areas where races may occur, and 
coincedentally so do the tg3 docs.  The tg3 docs suggest to me that in 
tg3_poll, after we unmask ints, we should
* flush the MMIO write
* check the status block for updates again
* tell tg3 to deliver to us an artificial interrupt just in case we 
raced [IMO preferred versus simply returning 'not-done' in tg3_poll retval]

But this is just a theory and not tested yet...
