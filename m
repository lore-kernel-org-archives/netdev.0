From: "Hubbe, Allen" <Allen.Hubbe@emc.com>
Subject: RE: CodingStyle parenthesis alignment: was: Re: align to open paren
Date: Wed, 15 Apr 2015 21:54:48 +0000
Message-ID: <40F65EF2B5E2254199711F58E3ACB84D781CD94F@MX104CL02.corp.emc.com>
References: <40F65EF2B5E2254199711F58E3ACB84D781CD892@MX104CL02.corp.emc.com>
 <1429131997.2850.15.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_003_40F65EF2B5E2254199711F58E3ACB84D781CD94FMX104CL02corpem_"
Cc: "apw@canonical.com" <apw@canonical.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429131997.2850.15.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_003_40F65EF2B5E2254199711F58E3ACB84D781CD94FMX104CL02corpem_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Wednesday, April 15, 2015 5:07 PM
> To: Hubbe, Allen
> Cc: apw@canonical.com; LKML; netdev
> Subject: CodingStyle parenthesis alignment: was: Re: align to open paren
>=20
> On Wed, 2015-04-15 at 20:34 +0000, Hubbe, Allen wrote:
> > Hello Andy, Joe,
>=20
> Hello Allen.
>=20
> As this is a discussion better suited for linux
> development lists I've cc'd LKML and netdev.
>=20
> > I would like to find the origin of the decision to align to the open
> > paren in Linux.
>=20
> Mostly it's a style decision shared by net/ and
> drivers/net/ and a few other directories.
>=20
> It's a checkpatch --strict only test so it's not on
> by default except in net/ and drivers/net/.
>=20

Thanks.

> > I found the commit where this was added a few years ago, d1fe9c0.
> > The email thread just says the style should be that way, but not why
> > or how the decision was made.  The how and the why is what I'm after,
> > since I have a critique of the chosen style.
> >
> > I realize there is a lot of code written using this stile, and
> > changing it would be disruptive.  I certainly would not ask for that.
> >
> > Indenting to the open paren might cause ambiguous indentation between
> > the parenthesized expression and the next logical thing.  In the
> > following, next_thing aligns to the same column as baz, even though
> > baz is part of the condition expression, and next_thing is the
> > continued statement.
> >
> > =3D if (foo(bar,
> > =3D         baz))
> > =3D         next_thing();
> >
> > It would be necessary to reindent to maintain style, even though the
> > code of the next lines is the same.  This has consequences like
> > changing the blame, for instance.  In the following, 4 + 5 is the bug,
> > but whoever replaced the global with an instance variable gets the
> > blame.
>=20
> blame is overrated.
> git blame -w ignores most of the whitespace noise.
>=20
> > =3D global_variable =3D foo(bar,
> > =3D                       baz(1 + 3),
> > =3D                       baz(4 + 5) + 6);
> > with
> > =3D obj->var =3D foo(bar,
> > =3D                baz(1 + 3),
> > =3D                baz(4 + 5) + 6);
> >
> > I'm used to the default in many editors, which is to indent twice
> > following each open paren, as opposed to once following each open
> > brace or continued statement.  It is a simpler rule for automatic
> > formatting to implement.  It also avoids mixing tabs and spaces, the
> > spacing is unambiguous, and to maintain style, there is no need to
> > re-indent lines following an edit if the position of the open paren
> > changes.
> >
> > It's interesting to me that this style is only enforced by
> > checkpatch.pl --strict.  It is not in Documents/CodingStyle.  That
> > being the case, would it be acceptable to relax the rule in
> > checkpatch.pl to accept either style?  If not, well, I'll just accept
> > the chosen style and fix my code.
>=20
> I personally don't care much either way.
>=20
> > If the following looks acceptable to you, I'll submit the patch to the
> > list.
>=20
> The patch most likely wouldn't be appropriate for
> net/ and drivers/net/ where the developers seem to
> strongly prefer alignment to open parenthesis.
>=20

I don't want to annoy the net developers.  Is it that the style is the same=
 across the kernel, just more strongly enforced in net, or do different sub=
system maintainers enforce different styles?  Again, I'll be happy to just =
accept the kernel style if that's the case.

> Also I think the open parenthesis count isn't right
> as it would ask for multiple indents for code like:
>=20
> 	if ((foo(bar)) &&
> 	    (baz(bar))) {

As this is properly indented to the open paren, it is accepted.

>=20
> I think checkpatch would now want:
>=20
> 	if ((foo(bar)) &&
> 					(baz(bar))) {
>=20

CHECK: Alignment should match open parenthesis, or be twice indented for ea=
ch open parenthesis
#51: FILE: foo.c:51:
+	if ((foo(bar)) &&
+					(baz(bar))) {

I count three opens and two closes in the first line, leaving one open pare=
n, but the second line is further indented by four instead of two.  That is=
 rejected, but it accepts this:

 	if ((foo(bar)) &&
			(baz(bar))) {

> and the --fix option would be wrong too.

I ran with the --fix option, and it changed every rejected indent to match =
the column of the open paren.  That's probably what you want, since it's th=
e most consistent with the previous behavior.  The difference is that it do=
es not fix lines that are no longer rejected, like if they are indented by =
two per paren.  The test file and output are attached.

>=20
> cheers, Joe
>=20
> > Thanks,
> > Allen
> >
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > index d124359..8e49125 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -1834,6 +1834,15 @@ sub pos_last_openparen {
> >         return length(expand_tabs(substr($line, 0, $last_openparen)))
> + 1;
> >  }
> >
> > +sub count_openparen {
> > +       my ($line) =3D @_;
> > +
> > +       my $opens =3D $line =3D~ tr/\(/\(/;
> > +       my $closes =3D $line =3D~ tr/\)/\)/;
> > +
> > +       return $opens - $closes;
> > +}
> > +
> >  sub process {
> >         my $filename =3D shift;
> >
> > @@ -2539,11 +2548,16 @@ sub process {
> >                                         " "  x ($pos % 8);
> >                                 my $goodspaceindent =3D $oldindent . " =
"
> x $pos;
> >
> > +                               my $goodtwotabindent =3D $oldindent .
> > +                                       "\t\t" x
> count_openparen($rest);
> > +
> >                                 if ($newindent ne $goodtabindent &&
> > -                                   $newindent ne $goodspaceindent) {
> > +                                   $newindent ne $goodspaceindent &&
> > +                                   $newindent ne $goodtwotabindent) {
> >
> >                                         if
> (CHK("PARENTHESIS_ALIGNMENT",
> > -                                               "Alignment should
> match open parenthesis\n" . $hereprev) &&
> > +                                               "Alignment should
> match open parenthesis, " .
> > +                                               "or be twice indented
> for each open parenthesis\n" . $hereprev) &&
> >                                             $fix && $line =3D~ /^\+/) {
> >                                                 $fixed[$fixlinenr] =3D~
> >                                                     s/^\+[
> \t]*/\+$goodtabindent/;
>=20
>=20


--_003_40F65EF2B5E2254199711F58E3ACB84D781CD94FMX104CL02corpem_
Content-Type: text/plain; name="foo.c"
Content-Description: foo.c
Content-Disposition: attachment; filename="foo.c"; size=624;
	creation-date="Wed, 15 Apr 2015 21:47:53 GMT";
	modification-date="Wed, 15 Apr 2015 21:47:19 GMT"
Content-Transfer-Encoding: base64

aW50IG1haW4oKSB7CglpZiAoKGZvbyhiYXIpKSAmJiAoYmF6KGJhcikpKSB7Cgl9CgoJLyogaW5k
ZW50IHRvIG9wZW4gcGFyZW4gKi8KCgkvKiBpbmNvcnJlY3QgKi8KCWlmICgoZm9vKGJhcikpICYm
CgkgICAoYmF6KGJhcikpKSB7Cgl9CgoJLyogY29ycmVjdCAqLwoJaWYgKChmb28oYmFyKSkgJiYK
CSAgICAoYmF6KGJhcikpKSB7Cgl9CgoJLyogaW5jb3JyZWN0ICovCglpZiAoKGZvbyhiYXIpKSAm
JgoJCShiYXooYmFyKSkpIHsKCX0KCgkvKiBpbmNvcnJlY3QgKi8KCWlmICgoZm9vKGJhcikpICYm
CgkJIChiYXooYmFyKSkpIHsKCX0KCgkvKiBpbmRlbnQgYnkgbnVtYmVyIG9mIHRhYnMgKi8KCgkv
KiBpbmNvcnJlY3QgKi8KCWlmICgoZm9vKGJhcikpICYmCgkoYmF6KGJhcikpKSB7Cgl9CgoJLyog
aW5jb3JyZWN0ICovCglpZiAoKGZvbyhiYXIpKSAmJgoJCShiYXooYmFyKSkpIHsKCX0KCgkvKiBj
b3JyZWN0ICovCglpZiAoKGZvbyhiYXIpKSAmJgoJCQkoYmF6KGJhcikpKSB7Cgl9CgoJLyogaW5j
b3JyZWN0ICovCglpZiAoKGZvbyhiYXIpKSAmJgoJCQkJKGJheihiYXIpKSkgewoJfQoKCS8qIGlu
Y29ycmVjdCAqLwoJaWYgKChmb28oYmFyKSkgJiYKCQkJCQkoYmF6KGJhcikpKSB7Cgl9Cn0K

--_003_40F65EF2B5E2254199711F58E3ACB84D781CD94FMX104CL02corpem_
Content-Type: application/octet-stream;
	name="foo.c.EXPERIMENTAL-checkpatch-fixes"
Content-Description: foo.c.EXPERIMENTAL-checkpatch-fixes
Content-Disposition: attachment;
	filename="foo.c.EXPERIMENTAL-checkpatch-fixes"; size=639;
	creation-date="Wed, 15 Apr 2015 21:47:53 GMT";
	modification-date="Wed, 15 Apr 2015 21:47:19 GMT"
Content-Transfer-Encoding: base64

aW50IG1haW4oKSAKewoJaWYgKChmb28oYmFyKSkgJiYgKGJheihiYXIpKSkgewoJfQoKCS8qIGlu
ZGVudCB0byBvcGVuIHBhcmVuICovCgoJLyogaW5jb3JyZWN0ICovCglpZiAoKGZvbyhiYXIpKSAm
JgoJICAgIChiYXooYmFyKSkpIHsKCX0KCgkvKiBjb3JyZWN0ICovCglpZiAoKGZvbyhiYXIpKSAm
JgoJICAgIChiYXooYmFyKSkpIHsKCX0KCgkvKiBpbmNvcnJlY3QgKi8KCWlmICgoZm9vKGJhcikp
ICYmCgkgICAgKGJheihiYXIpKSkgewoJfQoKCS8qIGluY29ycmVjdCAqLwoJaWYgKChmb28oYmFy
KSkgJiYKCSAgICAoYmF6KGJhcikpKSB7Cgl9CgoJLyogaW5kZW50IGJ5IG51bWJlciBvZiB0YWJz
ICovCgoJLyogaW5jb3JyZWN0ICovCglpZiAoKGZvbyhiYXIpKSAmJgoJICAgIChiYXooYmFyKSkp
IHsKCX0KCgkvKiBpbmNvcnJlY3QgKi8KCWlmICgoZm9vKGJhcikpICYmCgkgICAgKGJheihiYXIp
KSkgewoJfQoKCS8qIGNvcnJlY3QgKi8KCWlmICgoZm9vKGJhcikpICYmCgkJCShiYXooYmFyKSkp
IHsKCX0KCgkvKiBpbmNvcnJlY3QgKi8KCWlmICgoZm9vKGJhcikpICYmCgkgICAgKGJheihiYXIp
KSkgewoJfQoKCS8qIGluY29ycmVjdCAqLwoJaWYgKChmb28oYmFyKSkgJiYKCSAgICAoYmF6KGJh
cikpKSB7Cgl9Cn0K

--_003_40F65EF2B5E2254199711F58E3ACB84D781CD94FMX104CL02corpem_--
