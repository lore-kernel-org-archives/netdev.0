From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH net-next] xfrm: Call IP receive handler directly for
 inbound tunnel-mode packets
Date: Mon, 2 Jan 2012 14:52:36 -0500
Message-ID: <4F020B04.9000104@ll.mit.edu>
References: <1325475154-15997-1-git-send-email-david.ward@ll.mit.edu>
 <20120102072828.GA5380@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha1; boundary="------------ms030505020603040607020404"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:53160 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234Ab2ABTvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jan 2012 14:51:35 -0500
In-Reply-To: <20120102072828.GA5380@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms030505020603040607020404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Herbert,

On 01/02/2012 02:28 AM, Herbert Xu wrote:
> On Sun, Jan 01, 2012 at 10:32:34PM -0500, David Ward wrote:
>> For IPsec tunnel mode (or BEET mode), after inbound packets are xfrm'e=
d,
>> call the IPv4/IPv6 receive handler directly instead of calling netif_r=
x.
>> In addition to avoiding unneeded re-processing of the MAC layer, packe=
ts
>> will not be received a second time on network taps. (Note that outboun=
d
>> packets are only received on network taps post-xfrm, but inbound packe=
ts
>> were being received both pre- and post-xfrm. So now network taps will
>> receive packets in either direction only once, in the form that they g=
o
>> "over the wire".)
>>
>> Signed-off-by: David Ward<david.ward@ll.mit.edu>
>> Cc: Herbert Xu<herbert@gondor.apana.org.au>
> You can't do this as this may cause stack overruns if we nest
> too deeply.
Sorry if I'm missing something, but how are such overruns avoided on the =

outbound side?

> Changing the existing tap processing behaviour will also break
> existing setups.
Assuming there might be a better way to make this change, are there=20
examples of existing setups that would be negatively affected? From my=20
perspective this behavior is just an unintended artifact of xfrm'ed=20
packets being placed back into netif_rx, which only occurs for inbound=20
packets, and it complicates the usage of network taps on these=20
interfaces (i.e. how do you systematically determine whether any packet=20
is post-xfrm and was already seen in an earlier form?). It seems to me=20
that network taps operate at a lower layer than xfrm, and so xfrm should =

be invisible to the network taps. If users are, for example, capturing=20
ESP packets from a PF_PACKET socket and want to examine the decrypted=20
payload, I think the capture application should be responsible for the=20
decryption, just as it would be at higher layers with something like=20
SSL/TLS (and again for example, both protocols can be decrypted by=20
Wireshark when provided the keys).

I would appreciate your feedback.

David



--------------ms030505020603040607020404
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
h4HfOoHsBGFUMYQGMnL48b9p9mXwrJXo/WKFGe8l9+dLoOWMdZ+dvKQva9kEAAOnbIZ2xXSi
7EAz0AD/QPSwUnf8MYIDKjCCAyYCAQEwXzBRMQswCQYDVQQGEwJVUzEfMB0GA1UEChMWTUlU
IExpbmNvbG4gTGFib3JhdG9yeTEMMAoGA1UECxMDUEtJMRMwEQYDVQQDEwpNSVRMTCBDQS0y
Agodmr+JAAAAACaLMAkGBSsOAwIaBQCgggGgMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTEyMDEwMjE5NTIzNlowIwYJKoZIhvcNAQkEMRYEFDaezyRnfh+1
g7qZn4VBmZtgq0qVMF8GCSqGSIb3DQEJDzFSMFAwCwYJYIZIAWUDBAECMAoGCCqGSIb3DQMH
MA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUrDgMCBzANBggqhkiG9w0DAgIB
KDBuBgkrBgEEAYI3EAQxYTBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQgTGluY29s
biBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTICCh2aFRcA
AAAAJoowcAYLKoZIhvcNAQkQAgsxYaBfMFExCzAJBgNVBAYTAlVTMR8wHQYDVQQKExZNSVQg
TGluY29sbiBMYWJvcmF0b3J5MQwwCgYDVQQLEwNQS0kxEzARBgNVBAMTCk1JVExMIENBLTIC
Ch2aFRcAAAAAJoowDQYJKoZIhvcNAQEBBQAEggEANNXKZHpkgVBXaNMdQuNMWCwCp4z3gy56
n8GHr0tXPzkwEVw71dVZc/oABD+E8qt0DAFQbkJx6rjlPKcR//UOkyQ8KjVBeUJ9Y8zz8WZ6
XdNokn5YF4G9zWP5EK5QkI/9AHiM4kBkI4719j77bGyO8ZJesKcbX6toLtcdAGdOJ16GjREy
6LwYLe8OEceN90XyO3SOwDO2cwrHdOLUBehQ5Ynjft+hGVhU2rDsyJPg0BYdX8vExBiwVrQS
VButcAlhvTVA8axrr7atYUd9XIrYgR1f7IWxvYlnrc7U2GEKtb5F1CrLm6dsEkVBtTAf/YKF
tDwIU/zg/uzlVA06oo0kEAAAAAAAAA==
--------------ms030505020603040607020404--
