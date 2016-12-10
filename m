From: =?utf-8?Q?Dan_L=C3=BCdtke?= <mail@danrl.com>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Sat, 10 Dec 2016 23:18:14 +0100
Message-ID: <CE942916-BF45-44CC-A5F5-3838CF9C93BC@danrl.com>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
 <095cac5b-b757-6f4a-e699-8eedf9ed7221@stressinduktion.org>
 <87vauvhwdu.fsf@alice.fifthhorseman.net>
Mime-Version: 1.0 (Mac OS X Mail 10.1 \(3251\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Netdev <netdev@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <87vauvhwdu.fsf@alice.fifthhorseman.net>
List-Unsubscribe: <https://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <https://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org


> On 8 Dec 2016, at 05:34, Daniel Kahn Gillmor <dkg@fifthhorseman.net> wrote:
> 
> On Wed 2016-12-07 19:30:34 -0500, Hannes Frederic Sowa wrote:
>> Your custom protocol should be designed in a way you get an aligned ip
>> header. Most protocols of the IETF follow this mantra and it is always
>> possible to e.g. pad options so you end up on aligned boundaries for the
>> next header.
> 
> fwiw, i'm not convinced that "most protocols of the IETF follow this
> mantra".  we've had multiple discussions in different protocol groups
> about shaving or bloating by a few bytes here or there in different
> protocols, and i don't think anyone has brought up memory alignment as
> an argument in any of the discussions i've followed.
> 

If the trade-off is between 1 padding byte and 2 byte alignment versus 3 padding bytes and 4 byte alignment I would definitely opt for 3 padding bytes. I know how that waste feels like to a protocol designer, but I think it is worth it. Maybe the padding/reserved will be useful some day for an additional feature.

I remember alignment being discussed and taken very seriously in 6man a couple of times. Often, though, protocol designers did align without much discussion. Implementing unaligned protocols is a pain I've experienced first hand.
