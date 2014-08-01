From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/3] nftables: Convert nft_hash to use generic
 rhashtable
Date: Fri, 1 Aug 2014 14:49:01 +0100
Message-ID: <20140801134901.GD7331@casper.infradead.org>
References: <cover.1406891028.git.tgraf@suug.ch>
 <bd4d9fa542072358cb0bd77e493ec5785a1d9666.1406891028.git.tgraf@suug.ch>
 <53DB864B.2070205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, josh@joshtriplett.org,
	challa@noironetworks.com, walpole@cs.pdx.edu, dev@openvswitch.org,
	tklauser@distanz.ch, netfilter-devel@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53DB864B.2070205@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/01/14 at 02:21pm, Nikolay Aleksandrov wrote:
> Sorry for the late response but I just got around to check the 3rd patch now,
> so my question about this fragment is: before nft_hash_remove() would free the
> element after removal, but after this change I don't see where and when the
> removed element would get freed ?

You are right. Looking at this closer we were leaking references even
before the change because it would not call nft_data_uninit() to release
the data objects. So it should really just call nft_hash_elem_destroy().
