From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH RFC 19/26] arch/sparc: Add option to skip DMA
 sync as a part of map and unmap
Date: Mon, 24 Oct 2016 12:24:31 -0700
Message-ID: <CAKgT0Uc6_D-w2kUC2o_FKm-chCr1j+CkSe_wE-D8--gyrfyr0w@mail.gmail.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120607.16276.5989.stgit@ahduyck-blue-test.jf.intel.com> <20161024.142730.1316656811538193943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	sparclinux@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161024.142730.1316656811538193943.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2016 at 11:27 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Mon, 24 Oct 2016 08:06:07 -0400
>
>> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
>> avoid invoking cache line invalidation if the driver will just handle it
>> via a sync_for_cpu or sync_for_device call.
>>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: sparclinux@vger.kernel.org
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This is fine for avoiding the flush for performance reasons, but the
> chip isn't going to write anything back unless the device wrote into
> the area.

That is mostly what I am doing here.  The original implementation was
mostly for performance.  I am trying to take the attribute that was
already in place for ARM and apply it to all the other architectures.
So what will be happening now is that we call the map function with
this attribute set and then use the sync functions to map it to the
device and then pull the mapping later.

The idea is that if Jesper does his page pool stuff it would be
calling the map/unmap functions and then the drivers would be doing
the sync_for_cpu/sync_for_device.  I want to make sure the map is
cheap and we will have to call sync_for_cpu from the drivers anyway
since there is no guarantee if we will have a new page or be reusing
an existing one.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
