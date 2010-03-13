From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Code paths setting gso_size
Date: Sat, 13 Mar 2010 06:22:57 -0500
Message-ID: <4B9B7591.9080706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dan Carpenter <error27@gmail.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a new thread dedicated to a specific topic, spawned by an
earlier discussion.  I've CC'd only those that participated recently.

I've written:
# In this particular instance, I suggest that you take a look at all the
# places that gso_size is set, and cross index with all the code paths that
# place these TCP headers onto the txq without a check of doff -- as I did!
#
# I'll specifically mention the tun and virtio_net devices, but I'm also
# particularly concerned with af_packet.c and skbuff.c -- and the general
# problem with inet_lro.c, too.
#
# Amazingly enough, folks sometimes use Linux for routers....
#

Eric (and David) have written:
# Only *locally* generated trafic by linux kernel can enter this path.
#

So, let us begin with the tun device, and work our way through the others.
