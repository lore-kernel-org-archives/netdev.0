From: David Miller <davem@davemloft.net>
Subject: Re: [MERGE README] net --> net-next
Date: Mon, 23 Oct 2017 01:16:40 +0100 (WEST)
Message-ID: <20171023.011640.460279805189770122.davem@davemloft.net>
References: <20171022.135717.971703426919688431.davem@davemloft.net>
        <59EC9877.6080702@iogearbox.net>
        <59ECF46D.30903@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, john.fastabend@gmail.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932151AbdJWAQo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 20:16:44 -0400
In-Reply-To: <59ECF46D.30903@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 22 Oct 2017 21:41:33 +0200

> On 10/22/2017 03:09 PM, Daniel Borkmann wrote:
>> On 10/22/2017 02:57 PM, David Miller wrote:
>>>
>>> There were quite a few BPF conflicts during the merge I just did of
>>> 'net' into 'net-next'.
>>>
>>> In particular, all of the packet pointer branch tests in the verifier
>>> had to be resolved wrt. three different sets of changes.
>>>
>>> The off-by-one stuff.  The allowance of the 'data_end > ptr + x' form
>>> of packet pointer checks.  And finally, the metadata stuff.
>>>
>>> I would really appreciate an audit and double check of my merge work
>>> by the interested parties.
>>
>> I will do a review today in the evening, thanks David!
> 
> Looks good overall, I notices two things (in find_good_pkt_pointers()
> in the second loop the max_t(u16, ...) still exists instead of just
> max() in -net and in test_verifier the test cases for 'XDP pkt read'
> are split in the middle with other test cases for bpf_exit). I'll send
> a cleanup on Monday for this along with the matches for metadata part.

Thanks for taking a look, I was slightly stumped by the max_t() and decided
to keep it in the merge.  If both arms of the operation are u16 then indeed
it isn't necessary.

Thanks again!
