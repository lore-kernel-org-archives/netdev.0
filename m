From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next 3/3] nftables: Convert nft_hash to use generic rhashtable
Date: Fri, 01 Aug 2014 15:12:28 +0100
Message-ID: <0d77fb6a-4465-432f-9d6a-b1c1497a780b@email.android.com>
References: <cover.1406891028.git.tgraf@suug.ch> <bd4d9fa542072358cb0bd77e493ec5785a1d9666.1406891028.git.tgraf@suug.ch> <53DB864B.2070205@redhat.com> <20140801134901.GD7331@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	josh@joshtriplett.org, challa@noironetworks.com,
	walpole@cs.pdx.edu, dev@openvswitch.org, tklauser@distanz.ch,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>,
	Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140801134901.GD7331@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1. August 2014 14:49:01 GMT+01:00, Thomas Graf <tgraf@suug.ch> wrote:
>On 08/01/14 at 02:21pm, Nikolay Aleksandrov wrote:
>> Sorry for the late response but I just got around to check the 3rd
>patch now,
>> so my question about this fragment is: before nft_hash_remove() would
>free the
>> element after removal, but after this change I don't see where and
>when the
>> removed element would get freed ?
>
>You are right. Looking at this closer we were leaking references even
>before the change because it would not call nft_data_uninit() to
>release
>the data objects. So it should really just call
>nft_hash_elem_destroy().

No, the data uninit is performed by the set core. Just freeing it is fine.


