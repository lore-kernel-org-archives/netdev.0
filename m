From: bert hubert <ahu@ds9a.nl>
Subject: Re: off by one error in 3des cbc keying
Date: Mon, 11 Nov 2002 22:51:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021111215122.GA563@outpost.ds9a.nl>
References: <20021111200321.GA30957@outpost.ds9a.nl> <200211112135.AAA28650@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200211112135.AAA28650@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2002 at 12:35:38AM +0300, kuznet@ms2.inr.ac.ru wrote:

> It would be good if you made setkey -D before the entry expired
> and started "setkey -x >& pfkey.log &" to collect pfkey traffic.

Before the 30 second entry expired:

10.0.0.216 10.0.0.11 
	esp mode=transport spi=57115683(0x03678423) reqid=0(0x00000000)
	E: 3des-cbc  cc8e8e4f 91d41b7b ea6cbb3c 24a465cb a08b33aa c8ec1274
	A: hmac-sha1  f454ab03 3a803ca4 05239de3 100ce68f d283f10a
	seq=0x00000000 replay=4 flags=0x00000000 state=mature 
	created: Nov 11 22:42:38 2002	current: Nov 11 22:43:05 2002
	diff: 27(s)	hard: 600(s)	soft: 480(s)
	last:                     	hard: 0(s)	soft: 0(s)
	current: 0(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 0	hard: 0	soft: 0
	sadb_seq=2 pid=8126 refcnt=0
10.0.0.216 10.0.0.11 
	esp mode=transport spi=0(0x00000000) reqid=0(0x00000000)
	seq=0x00000000 replay=0 flags=0x00000000 state=larval 
	created: Nov 11 22:42:37 2002	current: Nov 11 22:43:05 2002
	diff: 28(s)	hard: 30(s)	soft: 0(s)
	last:                     	hard: 0(s)	soft: 0(s)
	current: 0(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 0	hard: 0	soft: 0
	sadb_seq=1 pid=8126 refcnt=0
10.0.0.11 10.0.0.216 
	esp mode=transport spi=222275495(0x0d3fa7a7) reqid=0(0x00000000)
	E: 3des-cbc  f5fbb657 9b12bea6 b7d2eeda 587a0961 8a94ff6e d7b79a28
	A: hmac-sha1  20c2a282 1909e8ab 1e4690c1 1ee6cb40 c6b24190
	seq=0x00000000 replay=4 flags=0x00000000 state=mature 
	created: Nov 11 22:42:38 2002	current: Nov 11 22:43:05 2002
	diff: 27(s)	hard: 600(s)	soft: 480(s)
	last:                     	hard: 0(s)	soft: 0(s)
	current: 0(bytes)	hard: 0(bytes)	soft: 0(bytes)
	allocated: 0	hard: 0	soft: 0
	sadb_seq=0 pid=8126 refcnt=0

The middle one disappears after 30 seconds.

Log:

22:42:37: INFO: isakmp.c:1689:isakmp_post_acquire(): IPsec-SA
request for 10.0.0.11 queued due to no phase1 found.
22:42:37: INFO: isakmp.c:794:isakmp_ph1begin_i(): initiate new
phase 1 negotiation: 10.0.0.216[500]<=>10.0.0.11[500]
22:42:37: INFO: isakmp.c:799:isakmp_ph1begin_i(): begin
Aggressive mode.
22:42:38: INFO: vendorid.c:128:check_vendorid(): received Vendor
ID: KAME/racoon
22:42:38: NOTIFY: oakley.c:2037:oakley_skeyid(): couldn't find
the proper pskey, try to get one by the peer's address.
22:42:38: INFO: isakmp.c:2417:log_ph1established(): ISAKMP-SA
established 10.0.0.216[500]-10.0.0.11[500]
spi:50397abe512587b4:7fbfed906953a464
22:42:38: INFO: isakmp.c:938:isakmp_ph2begin_i(): initiate new
phase 2 negotiation: 10.0.0.216[0]<=>10.0.0.11[0]
22:42:38: INFO: pfkey.c:1106:pk_recvupdate(): IPsec-SA
established: ESP/Transport 10.0.0.11->10.0.0.216 spi=222275495(0xd3fa7a7)
22:42:38: INFO: pfkey.c:1318:pk_recvadd(): IPsec-SA established:
ESP/Transport 10.0.0.216->10.0.0.11 spi=57115683(0x3678423)

22:43:07: INFO: pfkey.c:1364:pk_recvexpire(): IPsec-SA expired:
ESP/Transport 10.0.0.216->10.0.0.11 


pfkey.log:


22:42:37.809959 
sadb_msg{ version=2 type=6 errno=0 satype=3
  len=47 reserved=0 seq=14 pid=0
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=2 type=18 }
sadb_x_policy{ type=2 dir=2 id=81 }
sadb_ext{ len=37 type=13 }
sadb_prop{ replay=32
sadb_comb{ auth=2 encrypt=1 flags=0x0000 reserved=0x00000000
  auth_minbits=128 auth_maxbits=128 encrypt_minbits=64 encrypt_maxbits=64
  soft_alloc=0 hard_alloc=0 soft_bytes=0 hard_bytes=0
  soft_alloc=72000 hard_alloc=86400 soft_bytes=25200 hard_bytes=28800 }
sadb_comb{ auth=3 encrypt=1 flags=0x0000 reserved=0x00000000
  auth_minbits=160 auth_maxbits=160 encrypt_minbits=64 encrypt_maxbits=64
  soft_alloc=0 hard_alloc=0 soft_bytes=0 hard_bytes=0
  soft_alloc=72000 hard_alloc=86400 soft_bytes=25200 hard_bytes=28800 }
sadb_comb{ auth=2 encrypt=2 flags=0x0000 reserved=0x00000000
  auth_minbits=128 auth_maxbits=128 encrypt_minbits=192 encrypt_maxbits=192
  soft_alloc=0 hard_alloc=0 soft_bytes=0 hard_bytes=0
  soft_alloc=72000 hard_alloc=86400 soft_bytes=25200 hard_bytes=28800 }
sadb_comb{ auth=3 encrypt=2 flags=0x0000 reserved=0x00000000
  auth_minbits=160 auth_maxbits=160 encrypt_minbits=192 encrypt_maxbits=192
  soft_alloc=0 hard_alloc=0 soft_bytes=0 hard_bytes=0
  soft_alloc=72000 hard_alloc=86400 soft_bytes=25200 hard_bytes=28800 }
}

22:42:38.078871 
sadb_msg{ version=2 type=1 errno=0 satype=3
  len=10 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=255 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=255 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }

22:42:38.079002 
sadb_msg{ version=2 type=1 errno=0 satype=3
  len=24 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=0 state=0
  auth=0 encrypt=0 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=30, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=0, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:38.079056 
sadb_msg{ version=2 type=10 errno=0 satype=0
  len=2 reserved=0 seq=0 pid=8107

22:42:38.079073 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=24 reserved=0 seq=1 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=0 replay=0 state=0
  auth=0 encrypt=0 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=30, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=0, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050957, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:38.079122 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=24 reserved=0 seq=0 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=0 state=0
  auth=0 encrypt=0 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=30, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=0, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:38.144461 
sadb_msg{ version=2 type=2 errno=0 satype=3
  len=28 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=4 state=0
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=255 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=255 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= f5fbb657 9b12bea6 b7d2eeda 587a0961 8a94ff6e d7b79a28 }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= 20c2a282 1909e8ab 1e4690c1 1ee6cb40 c6b24190 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }

22:42:38.144673 
sadb_msg{ version=2 type=2 errno=0 satype=3
  len=27 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:38.144729 
sadb_msg{ version=2 type=2 errno=0 satype=3
  len=27 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:38.144836 
sadb_msg{ version=2 type=3 errno=0 satype=3
  len=28 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=57115683 replay=4 state=0
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=255 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=255 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= cc8e8e4f 91d41b7b ea6cbb3c 24a465cb a08b33aa c8ec1274 }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= f454ab03 3a803ca4 05239de3 100ce68f d283f10a }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }

22:42:38.144909 
sadb_msg{ version=2 type=3 errno=0 satype=3
  len=27 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=57115683 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:38.145008 
sadb_msg{ version=2 type=3 errno=0 satype=3
  len=27 reserved=0 seq=14 pid=8107
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=57115683 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:39.661881 
sadb_msg{ version=2 type=10 errno=0 satype=0
  len=2 reserved=0 seq=0 pid=8112

22:42:39.661992 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=35 reserved=0 seq=2 pid=8112
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=57115683 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= f454ab03 3a803ca4 05239de3 100ce68f d283f10a }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= cc8e8e4f 91d41b7b ea6cbb3c 24a465cb a08b33aa c8ec1274 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:39.662090 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=24 reserved=0 seq=1 pid=8112
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=0 replay=0 state=0
  auth=0 encrypt=0 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=30, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=0, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050957, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:42:39.662139 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=35 reserved=0 seq=0 pid=8112
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= 20c2a282 1909e8ab 1e4690c1 1ee6cb40 c6b24190 }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= f5fbb657 9b12bea6 b7d2eeda 587a0961 8a94ff6e d7b79a28 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:43:05.077434 
sadb_msg{ version=2 type=10 errno=0 satype=0
  len=2 reserved=0 seq=0 pid=8126

22:43:05.077549 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=35 reserved=0 seq=2 pid=8126
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=57115683 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= f454ab03 3a803ca4 05239de3 100ce68f d283f10a }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= cc8e8e4f 91d41b7b ea6cbb3c 24a465cb a08b33aa c8ec1274 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:43:05.077646 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=24 reserved=0 seq=1 pid=8126
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=0 replay=0 state=0
  auth=0 encrypt=0 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=30, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=0, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050957, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:43:05.077694 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=35 reserved=0 seq=0 pid=8126
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= 20c2a282 1909e8ab 1e4690c1 1ee6cb40 c6b24190 }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= f5fbb657 9b12bea6 b7d2eeda 587a0961 8a94ff6e d7b79a28 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:43:07.781122 
sadb_msg{ version=2 type=8 errno=0 satype=3
  len=20 reserved=0 seq=0 pid=0
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=0 replay=0 state=3
  auth=0 encrypt=0 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=30, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050957, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:43:11.444772 
sadb_msg{ version=2 type=10 errno=0 satype=0
  len=2 reserved=0 seq=0 pid=8130

22:43:11.444967 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=35 reserved=0 seq=1 pid=8130
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=57115683 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= f454ab03 3a803ca4 05239de3 100ce68f d283f10a }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= cc8e8e4f 91d41b7b ea6cbb3c 24a465cb a08b33aa c8ec1274 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

22:43:11.445063 
sadb_msg{ version=2 type=10 errno=0 satype=3
  len=35 reserved=0 seq=0 pid=8130
sadb_ext{ len=2 type=1 }
sadb_sa{ spi=222275495 replay=4 state=1
  auth=3 encrypt=2 flags=0x00000000 }
sadb_ext{ len=4 type=3 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=600, usetime=0 }
sadb_ext{ len=4 type=4 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=480, usetime=0 }
sadb_ext{ len=4 type=2 }
sadb_lifetime{ alloc=0, bytes=0
  addtime=1037050958, usetime=0 }
sadb_ext{ len=3 type=5 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a00000b  }
sadb_ext{ len=3 type=6 }
sadb_address{ proto=0 prefixlen=32 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 0a0000d8  }
sadb_ext{ len=3 type=7 }
sadb_address{ proto=255 prefixlen=0 reserved=0x0000 }
sockaddr{ len=16 family=2 port=0
 00000000  }
sadb_ext{ len=4 type=8 }
sadb_key{ bits=160 reserved=0
  key= 20c2a282 1909e8ab 1e4690c1 1ee6cb40 c6b24190 }
sadb_ext{ len=4 type=9 }
sadb_key{ bits=192 reserved=0
  key= f5fbb657 9b12bea6 b7d2eeda 587a0961 8a94ff6e d7b79a28 }
sadb_ext{ len=2 type=19 }
sadb_x_sa2{ mode=1 reqid=0
  reserved1=0 reserved2=0 sequence=0 }

> If you prepare "setkey -x >& pfkey.log &" it will make the things
> much easier to track. Please, remember, at the moment I do not have
> capabilities to make any experiments here. Probably, this is for good
> (stimulates imagination :-)), but I really need to have full information
> to debug and not to imagine too far. :-)

I can give you access to my computers if you want? I have three available
here.

I hope this helps. Full setup on both sides:

On 10.0.0.216:

#!/home/ahu/download/kametools/setkey/setkey -f
flush;
spdflush;

spdadd 10.0.0.216 10.0.0.11 tcp -P out ipsec
        esp/transport//require;

spdadd 10.0.0.11 10.0.0.216 tcp -P in ipsec  
        esp/transport//require;

On 10.0.0.11:

#!./setkey -f
flush;
spdflush;

spdadd 10.0.0.11 10.0.0.216 tcp -P out ipsec
	esp/transport//require;

spdadd 10.0.0.216 10.0.0.11 tcp -P in ipsec
	esp/transport//require;


racoon.conf, identical on both (verified):

path pre_shared_key "./psk.txt" ;

remote anonymous
{
 	exchange_mode aggressive,main;
	doi ipsec_doi;
	situation identity_only;

	my_identifier address;

	nonce_size 16;
	lifetime time 10 min;   # sec,min,hour
	initial_contact on;
	support_mip6 on;
	proposal_check obey;	# obey, strict or claim

	proposal {
                encryption_algorithm 3des;
		hash_algorithm sha1;
		authentication_method pre_shared_key ;
		dh_group 2 ;
	}
}

sainfo anonymous
{
 	pfs_group 1;
	lifetime time 10 min;
	encryption_algorithm 3des ;
	authentication_algorithm hmac_sha1;
	compression_algorithm deflate ;
}


Regards,

bert

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
