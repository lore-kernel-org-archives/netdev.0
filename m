From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/5] Add eth_proto_is_802_3 to provide
 improved means of checking Ethertype
Date: Tue, 05 May 2015 19:24:59 -0400 (EDT)
Message-ID: <20150505.192459.2030369260746371959.davem@davemloft.net>
References: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	pshelar@nicira.com
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbbEEXZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:25:02 -0400
In-Reply-To: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 04 May 2015 14:33:42 -0700

> This patch series implements and makes use of eth_proto_is_802_3().  The
> idea behind the function is to provide an optimized means of testing to
> determine if a given Ethertype value is a length or 802.3 protocol number.
> The standard path for this was to use ntohs(proto) and then perform a
> comparison.  This adds a slight cost as it usually requires either a 16b
> rotate or byte swap which can cost 1 cycle or more depending on the
> processor.
> 
> I had previously addressed this for eth_type_trans, however in doing so I had
> overlooked checking with sparse and had introduced a couple sparse warnings.
> The first patch in this series fixes those sparse warnings as well as does
> some additional optimization for big endian systems.  In addition it pushes
> the code out into a separate function which can then be used in the other
> patches to reduce the instruction count/processing time in those functions
> as well.

Series applied, thanks!
