From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net PATCH 1/2] ipv4: Restore fib_trie_flush_external function
 and fix call ordering
Date: Tue, 15 Nov 2016 21:31:40 +0100
Message-ID: <20161115203140.GC1783@nanopsycho.orion>
References: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
 <20161115104606.13711.37506.stgit@ahduyck-blue-test.jf.intel.com>
 <20161115195107.GB1783@nanopsycho.orion>
 <1479241747.681.105.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36346 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753741AbcKOUbn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 15:31:43 -0500
Received: by mail-wm0-f49.google.com with SMTP id g23so192165574wme.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 12:31:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479241747.681.105.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 15, 2016 at 09:29:09PM CET, alexander.h.duyck@intel.com wrote:
>On Tue, 2016-11-15 at 20:51 +0100, Jiri Pirko wrote:
>> Tue, Nov 15, 2016 at 11:46:06AM CET, alexander.h.duyck@intel.com wrote:
>> > 
>> > The patch that removed the FIB offload infrastructure was a bit too
>> > aggressive and also removed code needed to clean up us splitting the table
>> > if additional rules were added.  Specifically the function
>> > fib_trie_flush_external was called at the end of a new rule being added to
>> > flush the foreign trie entries from the main trie.
>> > 
>> > I updated the code so that we only call fib_trie_flush_external on the main
>> > table so that we flush the entries for local from main.  This way we don't
>> > call it for every rule change which is what was happening previously.
>> 
>> Well, the function was introduced by:
>> 
>> commit 104616e74e0b464d449fdd2ee2f547d2fad71610
>> Author: Scott Feldman <sfeldma@gmail.com>
>> Date:   Thu Mar 5 21:21:16 2015 -0800
>> 
>>     switchdev: don't support custom ip rules, for now
>>     
>>     Keep switchdev FIB offload model simple for now and don't allow custom ip
>>     rules.
>> 
>> Why this was not needed before? What changed in between:
>> 104616e74e0b464d449fdd2ee2f547d2fad71610 ("switchdev: don't support custom ip rules, for now")
>> and
>> 347e3b28c1ba2 ("switchdev: remove FIB offload infrastructure")
>
>We collapsed the two tables into one in commit 0ddcf43d5d4a ("ipv4: FIB
>Local/MAIN table collapse") which was submitted the next day.  Scott
>and I were working on things at the same time and the
>fib_table_flush_external function was something we had worked out that
>would allow him to take care of his use case and me to take care of
>cleaning up the tables after unmerging.

Okay. But please name the fuction differently, as it does not flush
external. Thanks!
