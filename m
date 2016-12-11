From: Willy Tarreau <w@1wt.eu>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Sun, 11 Dec 2016 17:44:13 +0100
Message-ID: <20161211164413.GA5090@1wt.eu>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
 <095cac5b-b757-6f4a-e699-8eedf9ed7221@stressinduktion.org>
 <87vauvhwdu.fsf@alice.fifthhorseman.net>
 <CE942916-BF45-44CC-A5F5-3838CF9C93BC@danrl.com>
 <20161211071501.GA32621@kroah.com>
 <CAHmME9q5ifwwishXjXYE3J=sVeR4jYY9fLUgs_FHCP594EZr6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org,
 =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
 LKML <linux-kernel@vger.kernel.org>, Jiri Benc <jbenc@redhat.com>,
 Hannes Frederic Sowa <hannes@stressinduktion.org>,
 Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 Felix Fietkau <nbd@nbd.name>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
Content-Disposition: inline
In-Reply-To: <CAHmME9q5ifwwishXjXYE3J=sVeR4jYY9fLUgs_FHCP594EZr6g@mail.gmail.com>
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

On Sun, Dec 11, 2016 at 03:50:31PM +0100, Jason A. Donenfeld wrote:
> 3. Add 3 bytes of padding, set to zero, to the encrypted section just
> before the IP header, marked for future use.
> Pros: satisfies IETF mantras, can use those extra bits in the future
> for interesting protocol extensions for authenticated peers.
> Cons: lowers MTU, marginally more difficult to implement but still
> probably just one or two lines of code.
> 
> Of these, I'm leaning toward (3).

Or 4) add one byte to the cleartext header for future use (mostly flags
maybe) and 2 bytes of padding to the encrypted header. This way you get
the following benefits :
  1) your encrypted text is at least 16-bit aligned, maybe it matters
     in your checksum computations on during decryption
  2) your MTU remains even, this is better for both ends
  3) you're free to add some bits either to the encrypted or the clear
     parts.

Just a suggestion :-)

Willy
