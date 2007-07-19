From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [Bugme-new] [Bug 8755] New: "ip -6 route change " behaves like
 "ip -6 route add"
Date: Thu, 19 Jul 2007 19:29:51 +0100
Message-ID: <469FAD9F.8050903@simon.arlott.org.uk>
References: <bug-8755-10286@http.bugzilla.kernel.org/> <20070714214731.baf38cb8.akpm@linux-foundation.org> <469A382E.6000104@trash.net> <469A6C23.60206@simon.arlott.org.uk> <469B6C3D.3070807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg=sha1; boundary="------------ms060504090000060504010202"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:33407 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760545AbXGSSaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 14:30:04 -0400
In-Reply-To: <469B6C3D.3070807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms060504090000060504010202
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 16/07/07 14:01, Patrick McHardy wrote:
> Simon Arlott wrote:
>>>>>Changing an existing route:
>>>>># ip -6 r show 2002::/16
>>>>>2002::/16 dev sit0  metric 1024  expires 4482618sec mtu 1480 advmss 7140
>>>>>hoplimit 4294967295
>>>>># ip -6 r change 2002::/16 dev sit0 mtu 1280
>>>>>RTNETLINK answers: File exists

> The code looks like it would support it properly. Please add a
> few printks to inet6_rtm_newaddr to find out what goes wrong.

Erm. It's routing configuration that's broken not address configuration
(ip doesn't even . Looking at route.c through to ip6_fib.c, it doesn't
support replacing routes at all.

$ grep NLM_F_ ipv4/fib_*.c ipv4/route.c ipv6/fib6_* ipv6/ip6_fib.c
ipv6/route.c

ipv4/fib_frontend.c:            cfg->fc_nlflags = NLM_F_CREATE;
ipv4/fib_frontend.c:            .fc_nlflags = NLM_F_CREATE | NLM_F_APPEND,
ipv4/fib_hash.c:                if (cfg->fc_nlflags & NLM_F_EXCL)
ipv4/fib_hash.c:                if (cfg->fc_nlflags & NLM_F_REPLACE) {
ipv4/fib_hash.c:                                  &cfg->fc_nlinfo,
NLM_F_REPLACE);
ipv4/fib_hash.c:                if (!(cfg->fc_nlflags & NLM_F_APPEND))
ipv4/fib_hash.c:        if (!(cfg->fc_nlflags & NLM_F_CREATE))
ipv4/fib_hash.c:                                          NLM_F_MULTI) <
0) {
ipv4/fib_trie.c:                if (cfg->fc_nlflags & NLM_F_EXCL)
ipv4/fib_trie.c:                if (cfg->fc_nlflags & NLM_F_REPLACE) {
ipv4/fib_trie.c:                                tb->tb_id,
&cfg->fc_nlinfo, NLM_F_REPLACE);
ipv4/fib_trie.c:                if (!(cfg->fc_nlflags & NLM_F_APPEND))
ipv4/fib_trie.c:        if (!(cfg->fc_nlflags & NLM_F_CREATE))
ipv4/route.c:                                    1, NLM_F_MULTI) <= 0) {

ipv6/route.c:                prefix, NLM_F_MULTI);

-- 
Simon Arlott

--------------ms060504090000060504010202
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIKYjCC
BS0wggMVoAMCAQICAwPL4zANBgkqhkiG9w0BAQUFADB5MRAwDgYDVQQKEwdSb290IENBMR4w
HAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmlu
ZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZzAeFw0wNzA3
MTMxNzAyMTNaFw0wOTA3MTIxNzAyMTNaMDkxFTATBgNVBAMTDFNpbW9uIEFybG90dDEgMB4G
CSqGSIb3DQEJARYRc2ltb25AZmlyZS5scDAuZXUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
ggEKAoIBAQDRuhAfZirhjoH83q+OKFXHWXCya8enq+elUWh91va4jvpIDcO1lidbtHEAuUtZ
k7XzfzsNGF7NxNpt+sQT9avuTQJcA0ue4Y7wReCGGPu0zv4s2oD5agapHdEo49FzKI92ta60
r0KfodZd/a9x5VftzE9B67TkPPOzWcRzFjF002XDujrJ90i2DRQVLN+NfIWl43aEzifz9Lhy
OsrRmpL3N6QO0c2fRAXrq0ppXEFGu8jRXAuvLNF05sfqZ3eGTni3k9mjt8W1vYKqhZnpOXe5
5kwSEVgqjwZ/doxxq0K6DfDcfhACnZetJH1Ih/FsvOU2UhBZHnRrP6Bv8s1DJiNFAgMBAAGj
gf0wgfowDAYDVR0TAQH/BAIwADBWBglghkgBhvhCAQ0ESRZHVG8gZ2V0IHlvdXIgb3duIGNl
cnRpZmljYXRlIGZvciBGUkVFIGhlYWQgb3ZlciB0byBodHRwOi8vd3d3LkNBY2VydC5vcmcw
QAYDVR0lBDkwNwYIKwYBBQUHAwQGCCsGAQUFBwMCBgorBgEEAYI3CgMEBgorBgEEAYI3CgMD
BglghkgBhvhCBAEwMgYIKwYBBQUHAQEEJjAkMCIGCCsGAQUFBzABhhZodHRwOi8vb2NzcC5j
YWNlcnQub3JnMBwGA1UdEQQVMBOBEXNpbW9uQGZpcmUubHAwLmV1MA0GCSqGSIb3DQEBBQUA
A4ICAQCigdZ19oN9zyud1hDvJLiO8RXb+nvY50kr3Spb+0T8BwSd8iXXHBWqosbMJNhRB/Mf
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
FWh0dHA6Ly93d3cuY2FjZXJ0Lm9yZzEiMCAGA1UEAxMZQ0EgQ2VydCBTaWduaW5nIEF1dGhv
cml0eTEhMB8GCSqGSIb3DQEJARYSc3VwcG9ydEBjYWNlcnQub3JnAgMDy+MwCQYFKw4DAhoF
AKCCAdswGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMDcwNzE5
MTgyOTUxWjAjBgkqhkiG9w0BCQQxFgQU6IZ/P37GLRZyfmYq77FekBFIRN8wUgYJKoZIhvcN
AQkPMUUwQzAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYF
Kw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAwDgYDVQQKEwdS
b290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENl
cnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9y
ZwIDA8vjMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290IENBMR4wHAYD
VQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmluZyBB
dXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwIDA8vjMA0GCSqG
SIb3DQEBAQUABIIBAHRE/J+X+ncawbHdePKqNXfHiixEJ6YOTIpAtixEEltbOPPWW4M1brOx
b3tl9WIAK9MieFznCC+zCeDgu7YQj3zULpz/BjKfyuF5+4CWTurqGFqS8rg+QxHUgKKDS7gi
zXaHDkm8eMHLApS+2oSxSZSihWcP3OneR3XI+xO7meVEB0h/D9r0pPfV/NquPSS/Zbca061u
2gMX2dNwUP4UyaS++nuRnQPDgtdNmff6DedE9KUYNjDi2U4OQ9lt5oMclpxy8aQ/SKdnQLpN
oy+b3U+iGA2ASqDEI4PfUT3WCL6ayYHTCgjZUewwcKZKtIAAd/UVqknBQVJBjMCCttMXU9kA
AAAAAAA=
--------------ms060504090000060504010202--
