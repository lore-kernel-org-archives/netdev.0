From: David Miller <davem@davemloft.net>
Subject: Re: net/dccp: dccp_create_openreq_child freed held lock
Date: Thu, 04 May 2017 09:53:19 -0400 (EDT)
Message-ID: <20170504.095319.42169195176229264.davem@davemloft.net>
References: <20170301153510.GE15145@kernel.org>
        <20170301154011.GF15145@kernel.org>
        <CAAeHK+wSrkrooaK=d6Od85hNNQbTSuPxe55DFFYWEuE5zSqmSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@kernel.org, arnaldo.melo@gmail.com, dvyukov@google.com,
        gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        edumazet@google.com, xiyou.wangcong@gmail.com,
        syzkaller@googlegroups.com
To: andreyknvl@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wSrkrooaK=d6Od85hNNQbTSuPxe55DFFYWEuE5zSqmSw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 4 May 2017 15:36:37 +0200

> On Wed, Mar 1, 2017 at 4:40 PM, Arnaldo Carvalho de Melo
> <acme@kernel.org> wrote:
>> Em Wed, Mar 01, 2017 at 12:35:10PM -0300, Arnaldo Carvalho de Melo escreveu:
>>> Em Wed, Mar 01, 2017 at 10:38:54AM +0100, Dmitry Vyukov escreveu:
>>> > Hello,
>>> >
>>> > I've got the following report while running syzkaller fuzzer on
>>> > 86292b33d4b79ee03e2f43ea0381ef85f077c760:
>>> >
>>> >
>>> > It seems that dccp_create_openreq_child needs to unlock the sock if
>>> > dccp_feat_activate_values fails.
>>>
>>> Yeah, can you please use the patch below, that mimics the error paths in
>>> sk_clone_new(), from where I think even the comment about it being a raw
>>
>> Argh, s/sk_clone_new()/sk_clone_lock()/g
> 
> Hi Arnaldo,
> 
> Could you send the patch?
> 
> We haven't seen these reports since we applied it.

It isn't necessary in the current tree.

Arnaldo created a helper sk_free_unlock_clone() which handles this situation
properly, and calls it from dccp_create_openreq_child().
