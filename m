From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running
 rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Mon, 16 May 2005 17:58:52 -0400
Message-ID: <4289179C.6090900@pobox.com>
References: <20050516025901.4b26ccf3.akpm@osdl.org> <E1DXdL8-0005mE-00@gondolin.me.apana.org.au> <5fc59ff3050516104367a8d5cd@mail.gmail.com> <20050516212957.GA19211@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>,
        Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, hejianj@cn.ibm.com,
        linuxppc64-dev@lists.linuxppc.org.sgi.com, anton@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050516212957.GA19211@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Mon, May 16, 2005 at 10:43:02AM -0700, Ganesh Venkatesan wrote:
> 
>>@@ -1708,11 +1778,15 @@ err_rx_clean_list:
>>
>> static void e100_down(struct nic *nic)
>> {
>>+#ifdef CONFIG_E100_NAPI
>>+       /* wait here for poll to complete */
>>+       netif_poll_disable(nic->netdev);
>>+#endif
> 
> 
> Sorry, you can't do that here since you're in softirq context and
> netif_poll_disable may sleep.

I think the intention is that e100_down() may sleep, from looking at all 
the callsites.

Only e100_tx_timeout() calls it in a context that prevents sleep.

	Jeff
