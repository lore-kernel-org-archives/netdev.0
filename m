From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Thu, 26 May 2005 06:00:00 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E056B8C25@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <ganesh.venkatesan@gmail.com>, <anton@samba.org>,
        <herbert@gondor.apana.org.au>, <jgarzik@pobox.com>,
        <linuxppc64-dev@lists.linuxppc.org.sgi.com>, <netdev@oss.sgi.com>,
        <rende@cn.ibm.com>, <wangjs@cn.ibm.com>, <cdlwangl@cn.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>, "Jian Jun He" <hejianj@cn.ibm.com>,
        "Ronciak, John" <john.ronciak@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jian:

We need more information on the test you run to get this hang. We have
not seen a hang similar to the one you describe. We have a p-series
machine in our lab and all we need is details on the test to run.

Thanks,
Ganesh.

>-----Original Message-----
>From: Andrew Morton [mailto:akpm@osdl.org]
>Sent: Thursday, May 26, 2005 12:38 AM
>To: Jian Jun He; Ronciak, John; Venkatesan, Ganesh; Brandeburg, Jesse
>Cc: ganesh.venkatesan@gmail.com; anton@samba.org;
>herbert@gondor.apana.org.au; jgarzik@pobox.com; linuxppc64-
>dev@lists.linuxppc.org.sgi.com; netdev@oss.sgi.com; rende@cn.ibm.com;
>wangjs@cn.ibm.com; cdlwangl@cn.ibm.com
>Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while
running
>rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
>
>Jian Jun He <hejianj@cn.ibm.com> wrote:
>>
>> I download e100-3.4.8 and installed in the test machine (both client
and
>>  server). But the server still hang while running rhr (network) test.
:(
>
>e100 is one of those drivers which we'd rather like to have working
>properly.
>
>Can we please confirm that a) this bug is not fixed in 2.6.12-rc5 and
b)
>nobody has seen a patch which fixes it?
>
>
>
>For reference:
>
>Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>
>> Andrew Morton <akpm@osdl.org> wrote:
>> >
>> > Might be a bug in the e100 driver, might not be.
>> >
>> > I assume this is the
>> >
>> >        BUG_ON(skb->list != NULL);
>>
>> It certainly is a bug in e100.
>>
>> e100_tx_timeout -> e100_down -> e100_rx_clean_list
>>
>> is racing against
>>
>> e100_poll -> e100_rx_clean -> e100_rx_indicate
>>
>> e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and
>> while it's being processed e100_rx_clean_list comes along and
>> frees it.
>>
>> >From a quick check similar problems may exist in other drivers that
>> have lockless ->poll() functions with RX rings.
