From: Stefan Rompf <srompf@isg.de>
Subject: Re: Deadlock in sungem/ip_auto_config/linkwatch
Date: Mon, 5 Jan 2004 17:50:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401051750.56233.srompf@isg.de>
References: <1073307882.2041.98320.camel@brick.watson.ibm.com> <200401051550.51063.srompf@isg.de> <1073319565.2043.98923.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pkcs7-signature";
  micalg=sha1;
  boundary="Boundary-02=_wXZ+/M91EO8KJ7L";
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ostrowski <mostrows@watson.ibm.com>
In-Reply-To: <1073319565.2043.98923.camel@brick.watson.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-02=_wXZ+/M91EO8KJ7L
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Montag, 05. Januar 2004 17:19 schrieb Michal Ostrowski:

> Suppose the linkwatch code backs-off in the case that rtnl_sem is held
> legitimately by thread A.  Meanwhile, thread B is doing a
> flush_scheduled_work in order to wait for pending linkwatch events to
> complete.

This won't happen. If a pending linkwatch event needs to be scheduled=20
synchronously (f.e. when a device is unregistered), it is executed in conte=
xt=20
of the calling process, not inside the workqueue thread.

> My initial though was to use a seperate work-queue, un-entangled with
> the global queue used for flush_scheduled_work. This would allow
> linkwatch events to be synchronized against explicitly.

That's overkill, and if I understand flush_workqueue() right, it doesn't ca=
re=20
about work that is queued with delay, so it even wouldn't help. That's why =
I=20
thought about a function to unregister pending work.

Stefan
=2D-=20
"doesn't work" is not a magic word to explain everything.

--Boundary-02=_wXZ+/M91EO8KJ7L
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Description: signature
Content-Disposition: attachment; filename="smime.p7s"

MIIGlwYJKoZIhvcNAQcCoIIGiDCCBoQCAQExCzAJBgUrDgMCGgUAMAsGCSqGSIb3DQEHAaCCBEAw
ggQ8MIIDpaADAgECAgFHMA0GCSqGSIb3DQEBBAUAMIG+MQswCQYDVQQGEwJERTEPMA0GA1UECBMG
SGVzc2VuMRowGAYDVQQHExFGcmFua2Z1cnQgYW0gTWFpbjEhMB8GA1UEChMYSW5ub3ZhdGl2ZSBT
b2Z0d2FyZSBHbWJIMR8wHQYDVQQLExZOZXR3b3JrIEFkbWluaXN0cmF0aW9uMSIwIAYDVQQDExlJ
U0cgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MRowGAYJKoZIhvcNAQkBFgtpbmZvQGlzZy5kZTAeFw0w
MDA2MDUxMjIyNDlaFw0xMDAzMDUxMjIyNDlaMIG6MQswCQYDVQQGEwJERTEPMA0GA1UECBMGSGVz
c2VuMRowGAYDVQQHExFGcmFua2Z1cnQgYW0gTWFpbjEhMB8GA1UEChMYSW5ub3ZhdGl2ZSBTb2Z0
d2FyZSBHbWJIMR0wGwYDVQQLExRTb2Z0d2FyZSBEZXZlbG9wbWVudDEeMBwGA1UEAxMVU3RlZmFu
IFJvbXBmIChJU0cgQ0EpMRwwGgYJKoZIhvcNAQkBFg1zcm9tcGZAaXNnLmRlMIGfMA0GCSqGSIb3
DQEBAQUAA4GNADCBiQKBgQDBTlj0vQ81p59aQUY3XX81RM0MrcLzq5l5VetfLQOS4aTmwk/32siO
rXQxxTwODgmui/kLzSgRRYqFtDfelSWvsrtYR4VaH3I1u7YgcXWTx4oTt0RdiMvJ3/VgKmfpbpRN
DlyuV7b8daC+0vpMKbhBJyt5716u9LHrMZZbw5n1gwIDAQABo4IBSjCCAUYwCQYDVR0TBAIwADAs
BglghkgBhvhCAQ0EHxYdT3BlblNTTCBHZW5lcmF0ZWQgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFHGF
b48a5LAWDpGcbEPw8Vn2aUYyMIHrBgNVHSMEgeMwgeCAFJyzCKYgVHSxntGNkKK4rHhml9G6oYHE
pIHBMIG+MQswCQYDVQQGEwJERTEPMA0GA1UECBMGSGVzc2VuMRowGAYDVQQHExFGcmFua2Z1cnQg
YW0gTWFpbjEhMB8GA1UEChMYSW5ub3ZhdGl2ZSBTb2Z0d2FyZSBHbWJIMR8wHQYDVQQLExZOZXR3
b3JrIEFkbWluaXN0cmF0aW9uMSIwIAYDVQQDExlJU0cgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MRow
GAYJKoZIhvcNAQkBFgtpbmZvQGlzZy5kZYIBADANBgkqhkiG9w0BAQQFAAOBgQAoJXnCqMVpxWXn
Q2Oo/Jv8YHL5qeNyFMBmmWPMgt+ecjt1roE6hPpr22bny5nWgLaFgvQk6DptEOkmxFOmFLUDjQUA
Rrypgr7Q5H3dILmsSKJPRWPiZPlwFtnA9Z7eSmnLbqF34kOmrt9NDPZxW/vx9fewVao2i0Fk0/n3
NpN0ETGCAh8wggIbAgEBMIHEMIG+MQswCQYDVQQGEwJERTEPMA0GA1UECBMGSGVzc2VuMRowGAYD
VQQHExFGcmFua2Z1cnQgYW0gTWFpbjEhMB8GA1UEChMYSW5ub3ZhdGl2ZSBTb2Z0d2FyZSBHbWJI
MR8wHQYDVQQLExZOZXR3b3JrIEFkbWluaXN0cmF0aW9uMSIwIAYDVQQDExlJU0cgQ2VydGlmaWNh
dGUgQXV0aG9yaXR5MRowGAYJKoZIhvcNAQkBFgtpbmZvQGlzZy5kZQIBRzAJBgUrDgMCGgUAoIGx
MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTA0MDEwNTE2NTA1Nlow
IwYJKoZIhvcNAQkEMRYEFMG1VMv2oQ9huoOf2E79m3hZ7W5TMFIGCSqGSIb3DQEJDzFFMEMwCgYI
KoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3
DQMCAgEoMA0GCSqGSIb3DQEBAQUABIGAMTE+Yg0t0/XRnOiw0D2VISwWOKjKKYnCkNdGHOkQWohJ
+7uLlc1+pv6C/PK1JEcOM82l9ynE/ddOpcuKGdxPxujXc4uSq+kx/lAc+rWw7xSXUxxQpPjyVz9g
oKDpnibM5P2dnVjyg0f7JZFUEILoPakkn/Rq8gG+VNvt2qr7RmM=

--Boundary-02=_wXZ+/M91EO8KJ7L--
