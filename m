From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 22 Sep 2017 11:03:55 +1000
Message-ID: <20170922110355.6a631fc5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Paolo Abeni <pabeni@redhat.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

net/ipv4/fib_frontend.c: In function 'fib_validate_source':
net/ipv4/fib_frontend.c:411:16: error: 'struct netns_ipv4' has no member named 'fib_has_custom_local_routes'
   if (net->ipv4.fib_has_custom_local_routes)
                ^
net/ipv4/fib_frontend.c: In function 'inet_rtm_newroute':
net/ipv4/fib_frontend.c:773:12: error: 'struct netns_ipv4' has no member named 'fib_has_custom_local_routes'
   net->ipv4.fib_has_custom_local_routes = true;
            ^

Caused by commit

  6e617de84e87 ("net: avoid a full fib lookup when rp_filter is disabled.")

This build has CONFIG_IP_MULTIPLE_TABLES unset.

I have reverted that commit for today.

-- 
Cheers,
Stephen Rothwell
