From: Richard Haines <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
Subject: Re: [PATCH] ss: Add support for retrieving SELinux contexts
Date: Fri, 21 Feb 2014 12:27:43 +0000 (GMT)
Message-ID: <1392985663.86285.YahooMailNeo@web87903.mail.ir2.yahoo.com>
References: <1392391214-14547-1-git-send-email-richard_c_haines@btinternet.com>
 <1392556690.15615.97.camel@deadeye.wl.decadent.org.uk>
Reply-To: Richard Haines <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org" <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
In-Reply-To: <1392556690.15615.97.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

I've updated the patch with your suggestions and rebuild using the latest g=
it
repository. Will send V2 patch today.

Thanks
Richard



----- Original Message -----
> From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
> To: Richard Haines <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
> Sent: Sunday, 16 February 2014, 13:18
> Subject: Re: [PATCH] ss: Add support for retrieving SELinux contexts
> =

> On Fri, 2014-02-14 at 15:20 +0000, Richard Haines wrote:
>>  The process SELinux contexts can be added to the output using the -Z
>>  option. Using the -z option will show the process and socket contexts (=
see
>>  the man page for details).
>>  For netlink sockets: if valid process show process context, if pid =3D 0
>>  show kernel initial context, if unknown show "not available".
>> =

>>  Signed-off-by: Richard Haines <richard_c_haines-FhtRXb7CoQBt1OO0OYaSVA@public.gmane.org>
>>  ---
>> =A0 configure=A0 =A0  |=A0 16 +++
>> =A0 man/man8/ss.8 |=A0 34 ++++++
>> =A0 misc/Makefile |=A0 12 ++
>> =A0 misc/ss.c=A0 =A0  | 375 =

> ++++++++++++++++++++++++++++++++++++++++++++++++++--------
>> =A0 4 files changed, 387 insertions(+), 50 deletions(-)
>> =

>>  diff --git a/configure b/configure
>>  index da01c19..854837e 100755
>>  --- a/configure
>>  +++ b/configure
>>  @@ -231,6 +231,19 @@ EOF
>> =A0 =A0 =A0 rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
>> =A0 }
>> =A0 =

>>  +check_selinux()
>>  +# SELinux is a compile time option in the ss utility
>>  +{
>>  +=A0=A0=A0 SELINUX_LIB=3D$(${PKG_CONFIG} --silence-errors libselinux --=
libs)
>>  +=A0=A0=A0 if [ -n "$SELINUX_LIB" ]
> =

> This should be just:
> =A0=A0=A0 if pkg-config libselinux --exists
> =

>>  +=A0=A0=A0 then
>>  +=A0=A0=A0 echo "HAVE_SELINUX:=3Dy" >>Config
>>  +=A0=A0=A0 echo "yes"
>>  +=A0 =A0 else
>>  +=A0=A0=A0 echo "no"
>>  +=A0=A0=A0 fi
>>  +}
> [...]
>>  --- a/misc/Makefile
>>  +++ b/misc/Makefile
>>  @@ -8,6 +8,18 @@ include ../Config
>> =A0 all: $(TARGETS)
>> =A0 =

>> =A0 ss: $(SSOBJ)
>>  +ifeq ($(HAVE_SELINUX),y)
>>  +=A0=A0=A0 $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SSOBJ) $(LDLIBS) -lselinux
> =

> This should use the output of 'pkg-config libselinux --libs'.
> =

>>  +else
>>  +=A0=A0=A0 $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SSOBJ) $(LDLIBS)
>>  +endif
>>  +
>>  +ss.o: ss.c
>>  +ifeq ($(HAVE_SELINUX),y)
>>  +=A0=A0=A0 $(CC) $(CFLAGS) -DHAVE_SELINUX -c $+
> =

> This should use the output of 'pkg-config libselinux --cflags'.
> =

>>  +else
>>  +=A0=A0=A0 $(CC) $(CFLAGS) -c $+
>>  +endif
> [...]
> =

> Ben.
> =

> -- =

> Ben Hutchings
> Any sufficiently advanced bug is indistinguishable from a feature.
> =


_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pUKDJzkOSz4g@public.gmane.org=
ov.
