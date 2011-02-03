From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 3 Feb 2011 14:10:51 -0800
Message-ID: <AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera> <AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
 <s5haaid3xos.wl%tiwai@suse.de> <201102032009.17100.rjw@sisk.pl> <AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001485eba1e80dd0f1049b680b26
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Takashi Iwai <tiwai@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Carlos Mafra <crmafra2@gmail.com>,
	Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001485eba1e80dd0f1049b680b26
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Feb 3, 2011 at 1:56 PM, Carlos Mafra <crmafra2@gmail.com> wrote:
>>
>> I added https://bugzilla.kernel.org/show_bug.cgi?id=24982 to the list of
>> post-2.6.36 regressions for further tracking.
>
> I also tested on 2.6.38-rc3+ now and the issue is not solved,
> just like Takashi expected.

Hmm. That commit (bf9dc102e284) still reverts cleanly.

Keith, Dave, should we just revert it? It's definitely a regression,
and we do _not_ allow "fixes" to one thing that just causes a
regression to another.

Quite frankly, I think it's totally wrong to just blindly set DPMS
status to ON like that. It's as wrong as it was to leave it off, and
the regressions reported are basically mirror images of the exact same
bug that that commit tried to fix.

IOW, the commit message says:

    When setting a new crtc configuration, force the DPMS state of all
    connectors to ON. Otherwise, they'll be left at OFF and a future mode set
    that disables the specified connector will not turn the connector off.

but setting it to ON doesn't actually _fix_ anything, because you just
get the exact same issue in reverse, ie you just get

   .. and a future mode set  that ENables the specified connector will
    not turn the connector ON.

instead. Which is exactly what Carlos and Takashi are reporting.

Maybe the right thing to do is to set it to 'unknown', something like this.

TOTALLY UNTESTED!

                          Linus

--001485eba1e80dd0f1049b680b26
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gjq7zjz50

IGRyaXZlcnMvZ3B1L2RybS9kcm1fY3J0Y19oZWxwZXIuYyB8ICAgIDYgKysrLS0tCiBpbmNsdWRl
L2RybS9kcm1fbW9kZS5oICAgICAgICAgICAgfCAgICAxICsKIDIgZmlsZXMgY2hhbmdlZCwgNCBp
bnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2Ry
bS9kcm1fY3J0Y19oZWxwZXIuYyBiL2RyaXZlcnMvZ3B1L2RybS9kcm1fY3J0Y19oZWxwZXIuYwpp
bmRleCA5NTJiM2Q0Li43ZjU4NWVkIDEwMDY0NAotLS0gYS9kcml2ZXJzL2dwdS9kcm0vZHJtX2Ny
dGNfaGVscGVyLmMKKysrIGIvZHJpdmVycy9ncHUvZHJtL2RybV9jcnRjX2hlbHBlci5jCkBAIC02
ODEsMTEgKzY4MSwxMSBAQCBpbnQgZHJtX2NydGNfaGVscGVyX3NldF9jb25maWcoc3RydWN0IGRy
bV9tb2RlX3NldCAqc2V0KQogCQkJZ290byBmYWlsOwogCQl9CiAJfQotCURSTV9ERUJVR19LTVMo
IlNldHRpbmcgY29ubmVjdG9yIERQTVMgc3RhdGUgdG8gb25cbiIpOworCURSTV9ERUJVR19LTVMo
IlNldHRpbmcgY29ubmVjdG9yIERQTVMgc3RhdGUgdG8gJ3Vua25vd24nXG4iKTsKIAlmb3IgKGkg
PSAwOyBpIDwgc2V0LT5udW1fY29ubmVjdG9yczsgaSsrKSB7Ci0JCURSTV9ERUJVR19LTVMoIlx0
W0NPTk5FQ1RPUjolZDolc10gc2V0IERQTVMgb25cbiIsIHNldC0+Y29ubmVjdG9yc1tpXS0+YmFz
ZS5pZCwKKwkJRFJNX0RFQlVHX0tNUygiXHRbQ09OTkVDVE9SOiVkOiVzXSBzZXQgRFBNUyAndW5r
bm93bidcbiIsIHNldC0+Y29ubmVjdG9yc1tpXS0+YmFzZS5pZCwKIAkJCSAgICAgIGRybV9nZXRf
Y29ubmVjdG9yX25hbWUoc2V0LT5jb25uZWN0b3JzW2ldKSk7Ci0JCXNldC0+Y29ubmVjdG9yc1tp
XS0+ZHBtcyA9IERSTV9NT0RFX0RQTVNfT047CisJCXNldC0+Y29ubmVjdG9yc1tpXS0+ZHBtcyA9
IERSTV9NT0RFX0RQTVNfVU5LTk9XTjsKIAl9CiAKIAlrZnJlZShzYXZlX2Nvbm5lY3RvcnMpOwpk
aWZmIC0tZ2l0IGEvaW5jbHVkZS9kcm0vZHJtX21vZGUuaCBiL2luY2x1ZGUvZHJtL2RybV9tb2Rl
LmgKaW5kZXggMGZjNzM5Ny4uNGI1MTQ0YyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9kcm0vZHJtX21v
ZGUuaAorKysgYi9pbmNsdWRlL2RybS9kcm1fbW9kZS5oCkBAIC01OSw2ICs1OSw3IEBACiAKIC8q
IERQTVMgZmxhZ3MgKi8KIC8qIGJpdCBjb21wYXRpYmxlIHdpdGggdGhlIHhvcmcgZGVmaW5pdGlv
bnMuICovCisjZGVmaW5lIERSTV9NT0RFX0RQTVNfVU5LTk9XTgkoLTEpCiAjZGVmaW5lIERSTV9N
T0RFX0RQTVNfT04JMAogI2RlZmluZSBEUk1fTU9ERV9EUE1TX1NUQU5EQlkJMQogI2RlZmluZSBE
Uk1fTU9ERV9EUE1TX1NVU1BFTkQJMgo=
--001485eba1e80dd0f1049b680b26--
