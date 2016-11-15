From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH 1/2] ipv4: Restore fib_trie_flush_external function
 and fix call ordering
Date: Tue, 15 Nov 2016 10:30:14 -0800
Message-ID: <1479234614.8455.125.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
         <20161115104606.13711.37506.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Jiri Pirko <jiri@mellanox.com>, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35057 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932951AbcKOSaP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:30:15 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so12439487pga.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:30:15 -0800 (PST)
In-Reply-To: <20161115104606.13711.37506.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-15 at 05:46 -0500, Alexander Duyck wrote:
> The patch that removed the FIB offload infrastructure was a bit too
> aggressive and also removed code needed to clean up us splitting the table
> if additional rules were added.  Specifically the function
> fib_trie_flush_external was called at the end of a new rule being added to
> flush the foreign trie entries from the main trie.
> 
> I updated the code so that we only call fib_trie_flush_external on the main
> table so that we flush the entries for local from main.  This way we don't
> call it for every rule change which is what was happening previously.
> 
> Fixes: 347e3b28c1ba2 ("switchdev: remove FIB offload infrastructure")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---


Acked-by: Eric Dumazet <edumazet@google.com>

Thanks for sorting this out Alex !
