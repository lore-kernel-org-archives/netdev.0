From: Jeff Mahoney <jeffm@suse.com>
Subject: Re: [PATCH] dl2k: Tighten ioctl permissions
Date: Wed, 25 Apr 2012 18:37:00 -0400
Message-ID: <4F987C8C.3090903@suse.com>
References: <4F985197.1060607@suse.com> <1335392802.2602.33.camel@bwh-desktop.uk.solarflarecom.com> <20120425.182954.804210541527871356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54688 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932107Ab2DYWhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 18:37:06 -0400
In-Reply-To: <20120425.182954.804210541527871356.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 04/25/2012 06:29 PM, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com> Date: Wed, 25 Apr
> 2012 23:26:42 +0100
> 
>> On Wed, 2012-04-25 at 15:33 -0400, Jeff Mahoney wrote:
>>> dl2k's rio_ioctl function defines several ioctls that involve 
>>> operations that should be denied to regular users.
>>> 
>>> SIOCDEVPRIVATE + 2 is a renumbered SIOCSMIIREG.
>> 
>> There was an early convention that SIOCDEVPRIVATE + {0,1,2} were
>> MDIO operations.  (This was a bad idea, because you can't safely
>> send them to an arbitrary driver... not that that stopped people
>> doing it.  Now it's neither safe to send them from userland, nor
>> to implement any other semantics for these ioctl numbers in a
>> driver.)
>> 
>> Please fix the numbering instead; it will make standard MII/MDIO 
>> utilities work and the capability check (in dev_ioctl()) comes
>> for free.
>> 
>>> SIOCDEVPRIVATE + 5 calls netif_stop_queue. SIOCDEVPRIVATE + 6
>>> calls netif_wake_queue.
>> [...]
>> 
>> And SIOCDEVPRIVATE + {7,8} spam the kernel log, so they should
>> perhaps be considered privileged too.
> 
> And I would also say that the netif_{stop,wake}_queue ones should
> just be deleted.  There is no sane way, even as a debugging
> facility, we can let useland trigger these conditions.
> 
> And if we could, it belongs in a generic facility no private
> ioctls which are heavily discouraged anyways.
> 
> I seriously would suggest ditching all of these private ioctls
> from the dl2k driver, I bet no binary in the world out there even
> exists which handles these strange renumbered MII operations.

Ok. I expected this is what you'd say, but I don't usually play in the
network code or have one of these devices to do any testing with. I'll
kill off the private ioctls and switch the MDIO ones to the standard
interface.

- -Jeff

- -- 
Jeff Mahoney
SUSE Labs
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBAgAGBQJPmHyMAAoJEB57S2MheeWyC2YQAIiUSuC3TTQkFW0sDdrGIJtB
BSfxeSJVYN6SOmKWK9G6/AsTciB/9z/d3lQ6duJQCFTZCnUcCWcKN81iIHRJVZ32
5f97MBnPnSbZvjGyaHT3QNodH6Jq0uNQRHAXm5py7RZpDGmYCFuEr/h5QRibbiH2
IoYG3QMSGUZysOsqYqzk1aHokSfp8CTkoUKHAAyvbo911M6eFO/V6vEQs2ujojDT
PZfXGYVqkegOvC3HyGjDuQaoMpUYQC1Uz343mNB6ZJVOM7SCVfN2R4cJGCD6K78s
dxbVl68jCfdI8cB5xv1vmWCsZroRlgjxmCnwyM/ecz0IAtmeGNjQXLoQF67WXcV+
hgUgVpcFK0bqCgrtkR1wxMdmloQHlXVf53FFxhIjkJc/KuSalhqdbMdMzKbcGtU/
aqx+1rl937sr8Ffg82qzpUqsunTDmQMV1EB87CdW5ma2ZkjekA3dn8za74OlhP3M
hYzytw7Z9rQQt0v5a2FAvYopLDMWgtl8bEgJf2Dnhyrnez0E4iDzIdQq6oYbtipQ
xndTUTmHJvIGbJfhtfiUZgG3LhKbFR6a+nz+P+Pk7TRqcuFUTaak0SkCjTBUdPGO
TIO2GqFJeAQR3s8F2na2AVzXHXeQrNoWaNlhU0EOt9GARSc+WjftApDbSrB+chKm
DP+N7odTX93FIzZ2/chy
=8eUd
-----END PGP SIGNATURE-----
