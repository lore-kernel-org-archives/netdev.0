From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] option for large routing hash
Date: Tue, 9 Dec 2003 12:20:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209122031.048b406f.davem@redhat.com>
References: <16341.58771.558850.163216@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16341.58771.558850.163216@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 9 Dec 2003 16:09:07 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> I think patch should be useful as it helps performance a lot during high 
> flow load. I have some numbers if you are interested.

I'm very hesitant about this, and it is not because I don't believe
that it brings better performance in your tests on your machines :)

Recently there was a thread on linux-kernel by the folks, such as Jes,
working on super-duper-huge NUMA boxes and how big the hash tables
get sized to on these machines.

In some of their configurations it was trying to allocate 1GB TCP
hash tables or something totally rediculious like this.

The problem with all of our current algorithms for size selection is
that it considers only one parameter when there are actually two.

It considers currently only relative memory consumption.  It needs
to also consider hard limits that exist for useful hash table sizes.

There is a point at which hash table size exceeds it's usefulness in
that the gains you are getting from the O(1) lookup are offset by the
fact that the access to the hash table heads are constantly taking cpu
cache misses.

You've obtained good results in your tests with a _specific_ hash
table size for the routing cache, but the algorithm you are proposing
for the kernel computes things relative to the amount of memory in the
machine.  It cannot be a function of only this parameter.

Do you see my point?
