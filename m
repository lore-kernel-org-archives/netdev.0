From: Gal Pressman <galp@mellanox.com>
Subject: Re: [PATCH ethtool] ethtool: Support for configurable RSS hash
 function
Date: Sun, 26 Mar 2017 13:50:23 +0300
Message-ID: <5a8eb943-9a99-7112-1105-12da745ccab1@mellanox.com>
References: <1488981831-19376-1-git-send-email-galp@mellanox.com>
 <20170325145047.6a5a7967@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eyal Perry <eyalpe@mellanox.com>
To: Jakub Kicinski <kubakici@wp.pl>,
        "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40077.outbound.protection.outlook.com ([40.107.4.77]:16625
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751271AbdCZLIS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 26 Mar 2017 07:08:18 -0400
In-Reply-To: <20170325145047.6a5a7967@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/03/2017 00:50, Jakub Kicinski wrote:
> On Wed,  8 Mar 2017 16:03:51 +0200, Gal Pressman wrote:
>> This ethtool patch adds support to set and get the current RSS hash
>> function for the device through the new hfunc mask field in the
>> ethtool_rxfh struct. Kernel supported hash function names are queried
>> with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
>> mask according to its index in the string-set.
>>
>> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
>> Signed-off-by: Gal Pressman <galp@mellanox.com>
>> Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
> Hi John,
>
> It seems you have applied both my earlier patch with get support and
> this:
>
> adbaa18b9bc1 ("ethtool: Support for configurable RSS hash function")
> b932835d2302 ("ethtool: print hash function with ethtool -x|--show-rxfh-indir")
>
> Now we print the RSS function twice:
>
> RX flow hash indirection table for em4 with 4 RX ring(s):
>     0:      [...]
> RSS hash function: toeplitz  <--- from my adbaa18b9bc1
> RSS hash key:
> Operation not supported
> RSS hash function:           <--- from this patch
>     toeplitz: on
>     xor: off
>     crc32: off
>
> Reverting my patch is probably the easiest way forward, although I find
> it more concise and easier to parse in test scripts :)
Hi Jakub,
Nice catch!

IMHO we should keep the output from my patch, as it is more informative.
This way the user can query all hash functions supported by the kernel using -x flag, before
trying to change them.
I think it's nicer than "guessing" what's supported and what's not :).
