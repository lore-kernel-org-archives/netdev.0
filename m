From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] option for large routing hash
Date: Wed, 10 Dec 2003 00:15:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210001556.71253d1f.davem@redhat.com>
References: <16341.58771.558850.163216@robur.slu.se>
	<20031209122031.048b406f.davem@redhat.com>
	<16342.19599.686693.823755@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16342.19599.686693.823755@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 9 Dec 2003 23:28:31 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> IP: routing cache hash table of 4096 buckets, 32Kbytes
 ...
> And tot+hit gives the pps throughput 152 kpps.
 ...
> IP: routing cache hash table of 32768 buckets, 256Kbytes
 ...
> We see cache is now used as hit > tot and we get a performance jump from 
> 152 to 265 kpps.
> 
> Just as you said this was the experiment. I'll stop here for now.

Thanks for the data.

I would eventually like an algorithm that uses a min/max range.
Perhaps something like:

const unsigned long rthash_min = PAGE_SIZE:
const unsigned long rthash_max = PAGE_ALIGN(512 * 1024 *
					    sizeof(struct rt_hash_bucket));

unsigned long rthash_choose_size(unsigned long num_physpages)
{
	unsigned long goal;

	goal = num_physpages >> (23 - PAGE_SHIFT);
	if (goal < rthash_min)
		goal = rthash_min;
	if (goal > rthash_max)
		goal = rthash_max;
	return goal;
}

It's a combination of your goal computation adjustment along with
sanity limits, that's all.
