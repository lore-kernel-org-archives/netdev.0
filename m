From: Wei Sun <unlcsewsun@gmail.com>
Subject: Re: A buggy behavior for Linux TCP Reno and HTCP
Date: Thu, 20 Jul 2017 16:28:02 -0500
Message-ID: <CANdGJ5SOUV1OoonC-3i=5MLUWvoHPBZgp19c3mJTTYbNr2yLeQ@mail.gmail.com>
References: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
 <CAK6E8=eP3jwTD5t7Cj3h_m4JTJ61p=roqsr02WiSHUANse1ynw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="94eb2c195c4e7df0250554c66c45"
Cc: netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38592 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935408AbdGTV2F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 17:28:05 -0400
Received: by mail-wm0-f53.google.com with SMTP id w191so37576496wmw.1
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 14:28:04 -0700 (PDT)
In-Reply-To: <CAK6E8=eP3jwTD5t7Cj3h_m4JTJ61p=roqsr02WiSHUANse1ynw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c195c4e7df0250554c66c45
Content-Type: text/plain; charset="UTF-8"

Hi Yuchung,

Sorry for the confusion.  The test case was adapted from an old DSACK
test case (i.e., forget to remove something).

Attached is a new and simple one. Thanks



On Wed, Jul 19, 2017 at 2:31 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Tue, Jul 18, 2017 at 2:36 PM, Wei Sun <unlcsewsun@gmail.com> wrote:
>> Hi there,
>>
>> We find a buggy behavior when using Linux TCP Reno and HTCP in low
>> bandwidth or highly congested network environments.
>>
>> In a simple word, their undo functions may mistakenly double the cwnd,
>> leading to a more aggressive behavior in a highly congested scenario.
>>
>>
>> The detailed reason:
>>
>> The current reno undo function assumes cwnd halving (and thus doubles
>> the cwnd), but it doesn't consider a corner case condition that
>> ssthresh is at least 2.
>>
>> e.g.,
>>                          cwnd              ssth
>> An initial state:     2                    5
>> A spurious loss:   1                    2
>> Undo:                   4                    5
>>
>> Here the cwnd after undo is two times as that before undo. Attached is
>> a simple script to reproduce it.
> the packetdrill script is a bit confusing: it disables SACK but then
> the client returns ACK w/ SACKs, also 3 dupacks happen after RTO so
> the sender isn't technically going through a fast recovery...
>
> could you provide a better test?
>
>>
>> A similar reason for HTCP, so we recommend to store the cwnd on loss
>> in .ssthresh implementation and restore it again in .undo_cwnd for TCP
>> Reno and HTCP implementations.
>>
>> Thanks

--94eb2c195c4e7df0250554c66c45
Content-Type: application/octet-stream; name="TSundo-2-1-4.pkt"
Content-Disposition: attachment; filename="TSundo-2-1-4.pkt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j5cy1im40

LyoqKioqKioqKioqKioqKgpBIHNpbXBlIHNjcmlwdCB0byB0cmlnZ2VyIHRoZSBidWcKdXNhZ2U6
CjEuIERvd25sb2FkIHBhY2tldGRyaWxsIHRvb2wgKGh0dHBzOi8vZ2l0aHViLmNvbS9nb29nbGUv
cGFja2V0ZHJpbGwvdHJlZS9tYXN0ZXIvZ3Rlc3RzL25ldC9wYWNrZXRkcmlsbCkgYW5kIHRoZW4g
cnVuIHRoaXMgc2NyaXB0CjIuIHN1ZG8gLi9wYWNrZXRkcmlsbCBUU3VuZG8tMi0xLTQucGt0IC0t
dG9sZXJhbmNlX3VzZWNzPTUwMDAwMAoKb3V0cHV0OgpbQmVmb3JlIGxvc3NdIGN3bmQ6IDIgc3N0
aDogNQpbRW50ZXIgbG9zc10gIGN3bmQ6IDEgc3N0aDogMgpbQWZ0ZXIgdW5kb10gIGN3bmQ6IDQg
c3N0aDogNQoqKioqKioqKioqKioqKioqKi8KKzAgYHN5c2N0bCAtcSBuZXQuaXB2NC50Y3BfY29u
Z2VzdGlvbl9jb250cm9sPXJlbm9gCiswIGBzeXNjdGwgLXEgbmV0LmlwdjQudGNwX3NhY2s9MGAK
Ci8vIEVzdGFibGlzaCBhIGNvbm5lY3Rpb24uCjAuMDAwIHNvY2tldCguLi4sIFNPQ0tfU1RSRUFN
LCBJUFBST1RPX1RDUCkgPSAzCjAuMDAwIHNldHNvY2tvcHQoMywgU09MX1NPQ0tFVCwgU09fUkVV
U0VBRERSLCBbMV0sIDQpID0gMAowLjAwMCBiaW5kKDMsIC4uLiwgLi4uKSA9IDAKMC4wMDAgbGlz
dGVuKDMsIDEpID0gMAoKMC4xMDAgPCBTIDA6MCgwKSB3aW4gNDIzNDAgPG1zcyAxMDEyLCBub3As
IG5vcCwgVFMgdmFsIDEwMCBlY3IgMD4KMC4xMDAgPiBTLiAwOjAoMCkgYWNrIDEgPG1zcyAxNDYw
LCBub3AsIG5vcCxUUyB2YWwgMTAwIGVjciAxMDA+CjAuMTEwIDwgLiAxOjEoMCkgYWNrIDEgd2lu
IDQyMzQwIDxub3Asbm9wLFRTIHZhbCAxMTAgZWNyIDEwMD4KMC4xMjAgYWNjZXB0KDMsIC4uLiwg
Li4uKSA9IDQKCi8vIFNlbmQgMiBNU1MuCjAuMTMgd3JpdGUoNCwgLi4uLCAyMDAwKSA9IDIwMDAK
MC4xMyA+IC4gMToxMDAxKDEwMDApIGFjayAxIDxub3AsIG5vcCwgVFMgdmFsIDEzMCBlY3IgMTEw
PgowLjEzID4gUC4gMTAwMToyMDAxKDEwMDApIGFjayAxIDxub3AsIG5vcCwgVFMgdmFsIDEzMCBl
Y3IgMTEwPgoKMC42ID4gLiAxOjEwMDEoMTAwMCkgYWNrIDEgPG5vcCxub3AsVFMgdmFsIDYwMCBl
Y3IgMTEwPgowLjcgPiAuIDE6MTAwMSgxMDAwKSBhY2sgMSA8bm9wLG5vcCxUUyB2YWwgNzAwIGVj
ciAxMTA+CgovL1RvIHRyaWdnZXIgc25kX2N3bmQ6MgowLjkgPCAuIDE6MSgwKSBhY2sgMTAwMSB3
aW4gMjU3IDxub3Asbm9wLFRTIHZhbCA5MDAgZWNyIDcwMD4KMC45ICV7cHJpbnQgIltCZWZvcmUg
TG9zc10gY3duZDoiLCB0Y3BpX3NuZF9jd25kLCAic3N0aDoiLCB0Y3BpX3NuZF9zc3RocmVzaH0l
CjEuMiA+IFAuIDEwMDE6MjAwMSgxMDAwKSBhY2sgMSA8bm9wLG5vcCxUUyB2YWwgMTIwMCBlY3Ig
OTAwPgoKLy8gVG8gdHJpZ2dlciBSVE8gdG8gZW50ZXIgYSBsb3NzCjEuNCAle3ByaW50ICJbRW50
ZXIgbG9zc10gY3duZDoiLCB0Y3BpX3NuZF9jd25kLCAic3N0aDoiLCB0Y3BpX3NuZF9zc3RocmVz
aH0lCgovL1RvIHRyaWdnZXIgdW5kbyBmb3IgdGhlIHByZXZpb3VzIGxvc3MKMS40IDwgLiAxOjEo
MCkgYWNrIDIwMDEgd2luIDI1NyA8bm9wLG5vcCxUUyB2YWwgMTQwMCBlY3IgMTMwPgoxLjQwMSAl
e3ByaW50ICJbQWZ0ZXIgdW5kb10gY3duZDoiLCB0Y3BpX3NuZF9jd25kLCAic3N0aDoiLCB0Y3Bp
X3NuZF9zc3RocmVzaH0lCgorMCBgc3lzY3RsIC1xIG5ldC5pcHY0LnRjcF9jb25nZXN0aW9uX2Nv
bnRyb2w9Y3ViaWNgCiswIGBzeXNjdGwgLXEgbmV0LmlwdjQudGNwX3NhY2s9MWAK
--94eb2c195c4e7df0250554c66c45--
