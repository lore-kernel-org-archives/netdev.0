From: Erik Slagter <erik@slagter.name>
Subject: Re: Various strange things with ipv6 local multicast forwarding
Date: Sun, 01 Feb 2009 11:57:43 +0100
Message-ID: <49858027.80304@slagter.name>
References: <498303B5.6090609@slagter.name> <50a66e370901311520h739ecc9bh5e14595d1ebb227e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms010102090601090505060709"
Cc: netdev@vger.kernel.org
To: Todd Hayton <todd.hayton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eriks.xs4all.nl ([83.160.41.216]:59538 "EHLO eriks.xs4all.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146AbZBAK5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Feb 2009 05:57:45 -0500
In-Reply-To: <50a66e370901311520h739ecc9bh5e14595d1ebb227e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms010102090601090505060709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Todd Hayton wrote:

>> Somehow I get the impression the ip6 multicast routing code in the kernel is
>> more targeted at multicast forwarding packets from outside the box than
>> packets locally generated :-/
> 
> This was my impression as well. From your setup your machine is not
> really acting as a multicast router per-se where you forward traffic
> received on interface A onto interfaces B, C, D...

Indeed. But how, am I asking myself, is one supposed to supply all real 
multicast routers with a stream... I guess somewhere a streaming server 
is required. This will only work (with linux) if the server only has one 
interface in use OR the serving application does the "multicasting" at 
application level (i.e. open multiple sockets and send the packets on 
them one by one) :-(

> My impression is
> that when you are sourcing the traffic you can only send it out of one
> interface (assuming you're doing only one call to sendto()). In fact,
> options like IP_MULTICAST_IF and IPV6_MULTICAST_IF let you specify an
> outgoing interface, but they only let you specify one outgoing
> interface.

This is actually not a problem in my opinion. These setsockopts are 
meant to be used by the multicast source application. Actually I want to 
have the multicast forwarding working without involvement of the source 
application, and imho it should work exactly like that. Kernel receives 
a packet from either an interface or internally generated (= lo?) and 
THEN applies the multicast routing for multicast destinations, simple as 
that!? My problem is that the kernel also uses and applies the normal 
routing table (with these strange ff00::/8 entries for each interface).

> My understanding was that when you are sending traffic the
> normal IP routing table is used to determine the outgoing interface.

Yes indeed. And I don't like that (for multicast traffic).

> In fact, on FreeBSD systems I've worked on you have to explicitly add
> a route to be able to send multicast traffic out of an interface (eg
> "route add -inet6 -net ff15:: -prefixlen 16 -interface le0") otherwise
> sendto() fails with "network is unreachable".

On linux it's exactly the same, the difference is that the multicast 
entries "pop up" automatically for each interface. But if you remove 
them, all kinds of apps that rely on multicasting (not per se multicast 
ROUTING) start to fail.

> As you've seen, the multicast route downloaded (via MFC_ADD) needs the
> incoming interface that the traffic is received on. Generally a
> multicast route doesn't get downloaded to the kernel *until* traffic
> starts showing up on some interface. The traffic then generates an
> upcall which is sent to the user space process which can then look at
> the traffic being sent and decide whether or not to download a route
> into the kernel (using MRT6_ADD_MFC). The decision on whether or not
> to download would be based on whether there were any interested
> receivers - which your application would know because it's monitoring
> the MLD reports.

Yes, I have that in consideration indeed. The absence of a multicast 
"cache" route or having a multicast "cache" route with no destination 
interfaces does not yield what's expected. In this case the normal 
routing table is consulted instead of the packet being dropped.

> Since you're not receiving the traffic from some other host, maybe you
> could make it look like you are to the kernel by connecting two of
> your interfaces back to back (say eth1 connects to eth2) using a
> crossover cable and then enabling multicasting on one of them (using
> MRT6_ADD_MIF) and then actually sending traffic out of the other one.
> This traffic then gets looped back onto the MIF, generates an upcall
> which your userland application gets and can then decide whether or
> not it wants to add a route for the traffic...Dunno if this setup
> would work but it's one idea...

Nah, that's too much a hack on a hack for me. I will try to work around 
the problems in userspace, I will even try to do some kernel hacking and 
I expect to have an acceptable setup in the end, although maybe with 
some workarounds (like the "dummy" interface).

Thanks for your efford.

I'd still like to have some comment from some of the netdev developers 
though... I think the whole thing is so overcomplicated. I would be very 
pleased with a simple mechanism, a "multicast" route in the normal 
routing table, that has multiple (interface) destinations. If you'd have 
a static setup, you wouldn't even need to have a multicast routing 
application to have it working, "ip route add" would suffice...

--------------ms010102090601090505060709
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIJUTCC
AwMwggJsoAMCAQICEGAvc086aOZ7ymp5a1XTLHcwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UE
BhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMT
I1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA4MDgxMTA4NDQzN1oX
DTA5MDgxMTA4NDQzN1owajEQMA4GA1UEBBMHU2xhZ3RlcjEVMBMGA1UEKhMMRXJpayBNYXJ0
aWpuMR0wGwYDVQQDExRFcmlrIE1hcnRpam4gU2xhZ3RlcjEgMB4GCSqGSIb3DQEJARYRZXJp
a0BzbGFndGVyLm5hbWUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDZCmPWWcxm
oBWTxF3SQ5eEvKXZykjWAU6TmmjKiECyrjRW6adVQfMCRmj8JOPQBFF2VKGD1+dY6yP/eOJE
nv58sM0JNJ9iSogxxYw9aTM4eRU7icMV3ZgXxLDmsx43Tgxmn2UkLX4qgJ7U4SexRawKebst
K+Jp93JfX9cGSx+YKvlHSLIgwEbJYoenuZb0LXsQKuswRLlsvYOz7KH06oXFDJqS2WETWHfY
VuFvcjHHUqx+ztG4gL5nl5wyEim1sk8w5GBRNiCd8SAw+SFUNjRLAcyAIqpkdfY+a2lWBL5n
eHtidBMll7zUgNIkHA9Yglp5c2ikCNckYnndFw1VCq3tAgMBAAGjLjAsMBwGA1UdEQQVMBOB
EWVyaWtAc2xhZ3Rlci5uYW1lMAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEFBQADgYEACfmg
IK9Bvs4w7cObGNNOPdt8MryEoPzr9raW48VewqJdl9o5G7iLEf9VCMxcX5VQ0M8aHNOhXgw9
urFzYSlJTBZp/dcO4Yj3VxEVe3vcIhsdyJOMD9E4MrrWJxtNihtYYa4Esm//SQ9lJ+GLgoyf
GjEGQ+QM6wKCMNwvu+RG4A8wggMDMIICbKADAgECAhBgL3NPOmjme8pqeWtV0yx3MA0GCSqG
SIb3DQEBBQUAMGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAo
UHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QTAeFw0wODA4MTEwODQ0MzdaFw0wOTA4MTEwODQ0MzdaMGoxEDAOBgNVBAQTB1NsYWd0ZXIx
FTATBgNVBCoTDEVyaWsgTWFydGlqbjEdMBsGA1UEAxMURXJpayBNYXJ0aWpuIFNsYWd0ZXIx
IDAeBgkqhkiG9w0BCQEWEWVyaWtAc2xhZ3Rlci5uYW1lMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEA2Qpj1lnMZqAVk8Rd0kOXhLyl2cpI1gFOk5poyohAsq40VumnVUHzAkZo
/CTj0ARRdlShg9fnWOsj/3jiRJ7+fLDNCTSfYkqIMcWMPWkzOHkVO4nDFd2YF8Sw5rMeN04M
Zp9lJC1+KoCe1OEnsUWsCnm7LSviafdyX1/XBksfmCr5R0iyIMBGyWKHp7mW9C17ECrrMES5
bL2Ds+yh9OqFxQyaktlhE1h32Fbhb3Ixx1Ksfs7RuIC+Z5ecMhIptbJPMORgUTYgnfEgMPkh
VDY0SwHMgCKqZHX2PmtpVgS+Z3h7YnQTJZe81IDSJBwPWIJaeXNopAjXJGJ53RcNVQqt7QID
AQABoy4wLDAcBgNVHREEFTATgRFlcmlrQHNsYWd0ZXIubmFtZTAMBgNVHRMBAf8EAjAAMA0G
CSqGSIb3DQEBBQUAA4GBAAn5oCCvQb7OMO3DmxjTTj3bfDK8hKD86/a2luPFXsKiXZfaORu4
ixH/VQjMXF+VUNDPGhzToV4MPbqxc2EpSUwWaf3XDuGI91cRFXt73CIbHciTjA/RODK61icb
TYobWGGuBLJv/0kPZSfhi4KMnxoxBkPkDOsCgjDcL7vkRuAPMIIDPzCCAqigAwIBAgIBDTAN
BgkqhkiG9w0BAQUFADCB0TELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTES
MBAGA1UEBxMJQ2FwZSBUb3duMRowGAYDVQQKExFUaGF3dGUgQ29uc3VsdGluZzEoMCYGA1UE
CxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEkMCIGA1UEAxMbVGhhd3RlIFBl
cnNvbmFsIEZyZWVtYWlsIENBMSswKQYJKoZIhvcNAQkBFhxwZXJzb25hbC1mcmVlbWFpbEB0
aGF3dGUuY29tMB4XDTAzMDcxNzAwMDAwMFoXDTEzMDcxNjIzNTk1OVowYjELMAkGA1UEBhMC
WkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1Ro
YXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMIGfMA0GCSqGSIb3DQEBAQUAA4GN
ADCBiQKBgQDEpjxVc1X7TrnKmVoeaMB1BHCd3+n/ox7svc31W/Iadr1/DDph8r9RzgHU5VAK
MNcCY1osiRVwjt3J8CuFWqo/cVbLrzwLB+fxH5E2JCoTzyvV84J3PQO+K/67GD4Hv0CAAmTX
p6a7n2XRxSpUhQ9IBH+nttE8YQRAHmQZcmC3+wIDAQABo4GUMIGRMBIGA1UdEwEB/wQIMAYB
Af8CAQAwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC50aGF3dGUuY29tL1RoYXd0ZVBl
cnNvbmFsRnJlZW1haWxDQS5jcmwwCwYDVR0PBAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYD
VQQDExFQcml2YXRlTGFiZWwyLTEzODANBgkqhkiG9w0BAQUFAAOBgQBIjNFQg+oLLswNo2as
Zw9/r6y+whehQ5aUnX9MIbj4Nh+qLZ82L8D0HFAgk3A8/a3hYWLD2ToZfoSxmRsAxRoLgnSe
JVCUYsfbJ3FXJY3dqZw5jowgT2Vfldr394fWxghOrvbqNOUQGls1TXfjViF4gtwhGTXeJLHT
HUb/XV9lTzGCA3EwggNtAgEBMHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBD
b25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFp
bCBJc3N1aW5nIENBAhBgL3NPOmjme8pqeWtV0yx3MAkGBSsOAwIaBQCgggHQMBgGCSqGSIb3
DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA5MDIwMTEwNTc0M1owIwYJKoZI
hvcNAQkEMRYEFOE8N3DFkhjufW9hTFoX5F3YNnhNMF8GCSqGSIb3DQEJDzFSMFAwCwYJYIZI
AWUDBAECMAoGCCqGSIb3DQMHMA4GCCqGSIb3DQMCAgIAgDANBggqhkiG9w0DAgIBQDAHBgUr
DgMCBzANBggqhkiG9w0DAgIBKDCBhQYJKwYBBAGCNxAEMXgwdjBiMQswCQYDVQQGEwJaQTEl
MCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3Rl
IFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0ECEGAvc086aOZ7ymp5a1XTLHcwgYcGCyqG
SIb3DQEJEAILMXigdjBiMQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRp
bmcgKFB0eSkgTHRkLjEsMCoGA1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3Vp
bmcgQ0ECEGAvc086aOZ7ymp5a1XTLHcwDQYJKoZIhvcNAQEBBQAEggEAd5EbwLjOtBw77VWD
LS7Y15zWOV1b0An8Iza7KVtdtj/Z80uS6f/9HkgBXxUe6OMBAVRZ+OmUibLui8nFOlJORnDT
jvGoQgzExjV6UYL8ufehH9Ru8p9ahPWDMJwyp5VtamM4iXyVLwP+8YOWKd3kYfoY5GQxYZBC
9d0XMeJRCZ5OacvcfE8AFJN3Ljy47RKq2tIpFPfmepki6OnVtbZmkTm9yTi2DvSw7M16O8De
vaNn1pbd/TVTSXFscXqU4s1+1dR0zdFQID/GJB4H6w4WjXhidifGLCq6q7t+DyWxHoaDZPeP
4gOja2ycAFmIu/RR7Sa3HDkeQeik6wX9ByT97gAAAAAAAA==
--------------ms010102090601090505060709--
