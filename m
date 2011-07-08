From: Roland Dreier <roland@purestorage.com>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 13:44:42 -0700
Message-ID: <CAL1RGDWTfchzBSv9rbgfg5DWvqB-Gi-RBpzDPGRUg96fNcf4Bw@mail.gmail.com>
References: <CABrhC0kaRCpvmKw=TdPZ+7dRFzdcrjF7hoc-VhbtAfXu=WBU_Q@mail.gmail.com>
 <20110708.110659.1816173367050101549.davem@davemloft.net> <CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
 <20110708.122742.1006323245708104141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:49362 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751539Ab1GHUpF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2011 16:45:05 -0400
Received: by qwc23 with SMTP id 23so1189456qwc.3
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2011 13:45:02 -0700 (PDT)
In-Reply-To: <20110708.122742.1006323245708104141.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Doesn't seem to matter much -- this is now equivalent to
>>
>> =A0 =A0 =A0 a =3D key ^ dev->ifindex
>> =A0 =A0 =A0 =A0return (a ^ (a >> 8) ^ (a >> 16) ^ (a >> 24)) =A0 =A0=
 =A0 =A0 =A0 // (1)
>> =A0 =A0 =A0 =A0 =A0 =A0 ^ (rnd ^ (rnd >> 8) ^ (rnd >> 16) ^ (rnd >> =
24)) =A0 // (2)
>>
>> where again the attacker controls (1), and (2) is a constant.

> Right, but how can you attack it? =A0Show me how you can grow
> a hash chain of arbitrary length by modulating the key in
> a deterministic way.

Well, if two things hash to different buckets with the full hash
function, then they already hashed to different buckets without
the extra randomness.  So why bother with hash_rnd?

The answer is that you have to mix hash_rnd into the hash
in a nonlinear way, so that an attacker can't know if two values
end up in the same bucket or not.

With your hash function, the attacker can just compute the
hash (without hash_rnd) for all the values of key ^ ifindex
and then use all the values that end up in the same bucket.

 - R.
