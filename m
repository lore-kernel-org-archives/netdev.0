From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: Re: [RFC] tcp: make H-TCP the default congestion control
Date: Fri, 28 Nov 2008 11:09:54 +0000
Message-ID: <2860327B-6E7F-435F-AB4A-36E66A49F7DE@nuim.ie>
References: <0EC70CEA-0C16-411E-9A50-6A0F23EA273F@nuim.ie>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_/iyQX/nMHZHe8B6epBEGIg)"
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:53730 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752019AbYK1LJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2008 06:09:56 -0500
Received: from [10.8.0.6] ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KB100HR3J0F3M30@mango.nuim.ie> for
 netdev@vger.kernel.org; Fri, 28 Nov 2008 11:09:53 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Boundary_(ID_/iyQX/nMHZHe8B6epBEGIg)
Content-type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-transfer-encoding: 7BIT

A bit of delayed input to this thread on netdev ...

> I'm not so sure about this logic, regardless of the algorithms
> involved.
>
> H-TCP was never the default in any distribution or release that
> I know of.  So it's real world exposure is effectively zero,
> which is the same as the new CUBIC stuff.

> They are effectively, therefore, equivalent choices.

Not really.  At this stage HTCP has undergone quite extensive  
independent testing by a good few groups (Caltech, Swinburne, North  
Carolina etc).  Its also been independently implemented in FreeBSD by  
the Swinburne folks.  Its true it hasn't been default in linux, but  
it HTCP  been subject to *far* more testing than the new cubic  
algorithm which has had no independent testing at all to my knowledge.

I'd also like to add some new input to the discussion on choice of  
congestion control algorithm in linux - and why it might be useful to  
evaluate alternatives like htcp.   Almost all of the proposals for  
changes to tcp (including cubic) have really slow convergence to  
fairness when new flows start up.   The question is then whether it  
matters e.g. whether it negatively impacts users.

To try to get a handle on this, we took one set of measurements from  
a home DSL line over a live link (so hopefully representative of  
common user experience), the other from a the production link out of  
the hamilton institute (so maybe more like the experience of  
enterprise users).   Plots of our measurements are at

http://www.hamilton.ie/doug/tina2.eps  (DSL link)
http://www.hamilton.ie/doug/caltech.eps  (hamilton link)

and also attached.

We started one long-ish flow (mimicking incumbent flows) and then  
started a second shorter flow.  The plots show the completion time of  
the second flow vs its connection size.  If the incumbent flow is  
slow to release bandwidth (as we expect with cubic), we expect the  
completion time of the second flow to increase, and indeed this is  
what we see.

What's particularly interesting is (i) the magnitude of the  
difference - completion times are consistently x2 with cubic vs htcp  
over many tests and (ii) that this effect is apparent not only on  
higher speed links (caltech.eps) but also on regular DSL links  
(tina2.eps - we took measurements from a home DSL line, so its not a  
sanitised lab setup or anything like that).

As might be expected, the difference in completion times eventually  
washes out for long transfers, e.g for the DSL link the most  
pronounced difference is for 1MB connections (where there is about a  
x2 difference in times between cubic and htcp) but becomes less for  
longer flows.  The point is that most real flows are short however,  
so the performance with a 1MB size flow seems like it should be more  
important than the 10MB size performance.  For me the DSL performance  
is the more important one here since it affects so many people, and  
was quite surprising, although I can also reproduce similar results  
on our testbed so its not a weird corner case or anything like that.

Wouldn't it be interesting to give h-tcp a go in linux to get wider  
feedback ?

Doug





--Boundary_(ID_/iyQX/nMHZHe8B6epBEGIg)
Content-type: application/postscript; x-unix-mode=0644; name=caltech.eps
Content-transfer-encoding: 7bit
Content-disposition: inline; filename=caltech.eps

%!PS-Adobe-3.0 EPSF-3.0
%%Creator: MATLAB, The Mathworks, Inc. Version 7.4.0.287 (R2007a). Operating System: Darwin 8.11.1 Darwin Kernel Version 8.11.1: Wed Oct 10 18:23:28 PDT 2007; root:xnu-792.25.20~1/RELEASE_I386 i386.
%%Title: /Users/douglasleith/Desktop/pfldnet2008/caltech.eps
%%CreationDate: 02/25/2008  21:08:39
%%DocumentNeededFonts: Helvetica
%%DocumentProcessColors: Cyan Magenta Yellow Black
%%LanguageLevel: 2
%%Pages: 1
%%BoundingBox:   -81   158   694   634
%%EndComments

%%BeginProlog
% MathWorks dictionary
/MathWorks 160 dict begin
% definition operators
/bdef {bind def} bind def
/ldef {load def} bind def
/xdef {exch def} bdef
/xstore {exch store} bdef
% operator abbreviations
/c  /clip ldef
/cc /concat ldef
/cp /closepath ldef
/gr /grestore ldef
/gs /gsave ldef
/mt /moveto ldef
/np /newpath ldef
/cm /currentmatrix ldef
/sm /setmatrix ldef
/rm /rmoveto ldef
/rl /rlineto ldef
/s {show newpath} bdef
/sc {setcmykcolor} bdef
/sr /setrgbcolor ldef
/sg /setgray ldef
/w /setlinewidth ldef
/j /setlinejoin ldef
/cap /setlinecap ldef
/rc {rectclip} bdef
/rf {rectfill} bdef
% page state control
/pgsv () def
/bpage {/pgsv save def} bdef
/epage {pgsv restore} bdef
/bplot /gsave ldef
/eplot {stroke grestore} bdef
% orientation switch
/portraitMode 0 def /landscapeMode 1 def /rotateMode 2 def
% coordinate system mappings
/dpi2point 0 def
% font control
/FontSize 0 def
/FMS {/FontSize xstore findfont [FontSize 0 0 FontSize neg 0 0]
  makefont setfont} bdef
/reencode {exch dup where {pop load} {pop StandardEncoding} ifelse
  exch dup 3 1 roll findfont dup length dict begin
  { 1 index /FID ne {def}{pop pop} ifelse } forall
  /Encoding exch def currentdict end definefont pop} bdef
/isroman {findfont /CharStrings get /Agrave known} bdef
/FMSR {3 1 roll 1 index dup isroman {reencode} {pop pop} ifelse
  exch FMS} bdef
/csm {1 dpi2point div -1 dpi2point div scale neg translate
 dup landscapeMode eq {pop -90 rotate}
  {rotateMode eq {90 rotate} if} ifelse} bdef
% line types: solid, dotted, dashed, dotdash
/SO { [] 0 setdash } bdef
/DO { [.5 dpi2point mul 4 dpi2point mul] 0 setdash } bdef
/DA { [6 dpi2point mul] 0 setdash } bdef
/DD { [.5 dpi2point mul 4 dpi2point mul 6 dpi2point mul 4
  dpi2point mul] 0 setdash } bdef
% macros for lines and objects
/L {lineto stroke} bdef
/MP {3 1 roll moveto 1 sub {rlineto} repeat} bdef
/AP {{rlineto} repeat} bdef
/PDlw -1 def
/W {/PDlw currentlinewidth def setlinewidth} def
/PP {closepath eofill} bdef
/DP {closepath stroke} bdef
/MR {4 -2 roll moveto dup  0 exch rlineto exch 0 rlineto
  neg 0 exch rlineto closepath} bdef
/FR {MR stroke} bdef
/PR {MR fill} bdef
/L1i {{currentfile picstr readhexstring pop} image} bdef
/tMatrix matrix def
/MakeOval {newpath tMatrix currentmatrix pop translate scale
0 0 1 0 360 arc tMatrix setmatrix} bdef
/FO {MakeOval stroke} bdef
/PO {MakeOval fill} bdef
/PD {currentlinewidth 2 div 0 360 arc fill
   PDlw -1 eq not {PDlw w /PDlw -1 def} if} def
/FA {newpath tMatrix currentmatrix pop translate scale
  0 0 1 5 -2 roll arc tMatrix setmatrix stroke} bdef
/PA {newpath tMatrix currentmatrix pop	translate 0 0 moveto scale
  0 0 1 5 -2 roll arc closepath tMatrix setmatrix fill} bdef
/FAn {newpath tMatrix currentmatrix pop translate scale
  0 0 1 5 -2 roll arcn tMatrix setmatrix stroke} bdef
/PAn {newpath tMatrix currentmatrix pop translate 0 0 moveto scale
  0 0 1 5 -2 roll arcn closepath tMatrix setmatrix fill} bdef
/vradius 0 def /hradius 0 def /lry 0 def
/lrx 0 def /uly 0 def /ulx 0 def /rad 0 def
/MRR {/vradius xdef /hradius xdef /lry xdef /lrx xdef /uly xdef
  /ulx xdef newpath tMatrix currentmatrix pop ulx hradius add uly
  vradius add translate hradius vradius scale 0 0 1 180 270 arc 
  tMatrix setmatrix lrx hradius sub uly vradius add translate
  hradius vradius scale 0 0 1 270 360 arc tMatrix setmatrix
  lrx hradius sub lry vradius sub translate hradius vradius scale
  0 0 1 0 90 arc tMatrix setmatrix ulx hradius add lry vradius sub
  translate hradius vradius scale 0 0 1 90 180 arc tMatrix setmatrix
  closepath} bdef
/FRR {MRR stroke } bdef
/PRR {MRR fill } bdef
/MlrRR {/lry xdef /lrx xdef /uly xdef /ulx xdef /rad lry uly sub 2 div def
  newpath tMatrix currentmatrix pop ulx rad add uly rad add translate
  rad rad scale 0 0 1 90 270 arc tMatrix setmatrix lrx rad sub lry rad
  sub translate rad rad scale 0 0 1 270 90 arc tMatrix setmatrix
  closepath} bdef
/FlrRR {MlrRR stroke } bdef
/PlrRR {MlrRR fill } bdef
/MtbRR {/lry xdef /lrx xdef /uly xdef /ulx xdef /rad lrx ulx sub 2 div def
  newpath tMatrix currentmatrix pop ulx rad add uly rad add translate
  rad rad scale 0 0 1 180 360 arc tMatrix setmatrix lrx rad sub lry rad
  sub translate rad rad scale 0 0 1 0 180 arc tMatrix setmatrix
  closepath} bdef
/FtbRR {MtbRR stroke } bdef
/PtbRR {MtbRR fill } bdef
/stri 6 array def /dtri 6 array def
/smat 6 array def /dmat 6 array def
/tmat1 6 array def /tmat2 6 array def /dif 3 array def
/asub {/ind2 exch def /ind1 exch def dup dup
  ind1 get exch ind2 get sub exch } bdef
/tri_to_matrix {
  2 0 asub 3 1 asub 4 0 asub 5 1 asub
  dup 0 get exch 1 get 7 -1 roll astore } bdef
/compute_transform {
  dmat dtri tri_to_matrix tmat1 invertmatrix 
  smat stri tri_to_matrix tmat2 concatmatrix } bdef
/ds {stri astore pop} bdef
/dt {dtri astore pop} bdef
/db {2 copy /cols xdef /rows xdef mul dup 3 mul string
  currentfile 
  3 index 0 eq {/ASCIIHexDecode filter}
  {/ASCII85Decode filter 3 index 2 eq {/RunLengthDecode filter} if }
  ifelse exch readstring pop
  dup 0 3 index getinterval /rbmap xdef
  dup 2 index dup getinterval /gbmap xdef
  1 index dup 2 mul exch getinterval /bbmap xdef pop pop}bdef
/it {gs np dtri aload pop moveto lineto lineto cp c
  cols rows 8 compute_transform 
  rbmap gbmap bbmap true 3 colorimage gr}bdef
/il {newpath moveto lineto stroke}bdef
currentdict end def
%%EndProlog

%%BeginSetup
MathWorks begin

0 cap

end
%%EndSetup

%%Page: 1 1
%%BeginPageSetup
%%PageBoundingBox:   -81   158   694   634
MathWorks begin
bpage
%%EndPageSetup

%%BeginObject: obj1
bplot

/dpi2point 12 def
portraitMode -0972 7608 csm

    0     0  9302  5709 rc
85 dict begin %Colortable dictionary
/c0 { 0.000000 0.000000 0.000000 sr} bdef
/c1 { 1.000000 1.000000 1.000000 sr} bdef
/c2 { 0.900000 0.000000 0.000000 sr} bdef
/c3 { 0.000000 0.820000 0.000000 sr} bdef
/c4 { 0.000000 0.000000 0.800000 sr} bdef
/c5 { 0.910000 0.820000 0.320000 sr} bdef
/c6 { 1.000000 0.260000 0.820000 sr} bdef
/c7 { 0.000000 0.820000 0.820000 sr} bdef
c0
1 j
1 sg
   0    0 9303 5710 rf
6 w
0 4653 7209 0 0 -4653 1209 5081 4 MP
PP
-7209 0 0 4653 7209 0 0 -4653 1209 5081 5 MP stroke
4 w
DO
SO
6 w
0 sg
1209 5081 mt 8418 5081 L
1209  428 mt 8418  428 L
1209 5081 mt 1209  428 L
8418 5081 mt 8418  428 L
1209 5081 mt 8418 5081 L
1209 5081 mt 1209  428 L
1209 5081 mt 1209 5008 L
1209  428 mt 1209  500 L
%%IncludeResource: font Helvetica
/Helvetica /ISOLatin1Encoding 216 FMSR

1089 5316 mt 
(40) s
2057 5081 mt 2057 5008 L
2057  428 mt 2057  500 L
1937 5316 mt 
(60) s
2905 5081 mt 2905 5008 L
2905  428 mt 2905  500 L
2785 5316 mt 
(80) s
3753 5081 mt 3753 5008 L
3753  428 mt 3753  500 L
3573 5316 mt 
(100) s
4601 5081 mt 4601 5008 L
4601  428 mt 4601  500 L
4421 5316 mt 
(120) s
5449 5081 mt 5449 5008 L
5449  428 mt 5449  500 L
5269 5316 mt 
(140) s
6297 5081 mt 6297 5008 L
6297  428 mt 6297  500 L
6117 5316 mt 
(160) s
7145 5081 mt 7145 5008 L
7145  428 mt 7145  500 L
6965 5316 mt 
(180) s
7993 5081 mt 7993 5008 L
7993  428 mt 7993  500 L
7813 5316 mt 
(200) s
1209 5081 mt 1281 5081 L
8418 5081 mt 8345 5081 L
1054 5161 mt 
(0) s
1209 4615 mt 1281 4615 L
8418 4615 mt 8345 4615 L
 934 4695 mt 
(10) s
1209 4150 mt 1281 4150 L
8418 4150 mt 8345 4150 L
 934 4230 mt 
(20) s
1209 3685 mt 1281 3685 L
8418 3685 mt 8345 3685 L
 934 3765 mt 
(30) s
1209 3219 mt 1281 3219 L
8418 3219 mt 8345 3219 L
 934 3299 mt 
(40) s
1209 2754 mt 1281 2754 L
8418 2754 mt 8345 2754 L
 934 2834 mt 
(50) s
1209 2289 mt 1281 2289 L
8418 2289 mt 8345 2289 L
 934 2369 mt 
(60) s
1209 1823 mt 1281 1823 L
8418 1823 mt 8345 1823 L
 934 1903 mt 
(70) s
1209 1358 mt 1281 1358 L
8418 1358 mt 8345 1358 L
 934 1438 mt 
(80) s
1209  893 mt 1281  893 L
8418  893 mt 8345  893 L
 934  973 mt 
(90) s
1209  428 mt 1281  428 L
8418  428 mt 8345  428 L
 814  508 mt 
(100) s
1209 5081 mt 8418 5081 L
1209  428 mt 8418  428 L
1209 5081 mt 1209  428 L
8418 5081 mt 8418  428 L
gs 1209 428 7210 4654 rc
24 w
/c8 { 0.000000 0.000000 1.000000 sr} bdef
c8
4240 -836 2120 -1058 1633 4079 3 MP stroke
DA
/c9 { 0.000000 0.500000 0.000000 sr} bdef
c9
4240 -816 2120 -562 1633 4624 3 MP stroke
SO
6 w
gr

c9
24 W
c8
3753 2246 PD
24 W
7993 2117 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 3211 PD
24 W
7993 3894 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 2563 PD
24 W
7993 3972 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 2895 PD
24 W
7993 1668 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 2524 PD
24 W
7993 1616 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 1772 PD
24 W
7993 1279 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 4037 PD
24 W
7993 3357 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 3253 PD
24 W
7993 1719 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 3015 PD
24 W
7993 448 PD
gs 1209 428 7210 4654 rc
gr

24 W
3753 4693 PD
24 W
7993 1783 PD
gs 1209 428 7210 4654 rc
gr

/c10 { 1.000000 0.000000 0.000000 sr} bdef
c10
3728 3837 mt 3778 3887 L
3778 3837 mt 3728 3887 L
7968 3426 mt 8018 3476 L
8018 3426 mt 7968 3476 L
gs 1209 428 7210 4654 rc
gr

3728 3840 mt 3778 3890 L
3778 3840 mt 3728 3890 L
7968 2824 mt 8018 2874 L
8018 2824 mt 7968 2874 L
gs 1209 428 7210 4654 rc
gr

3728 4118 mt 3778 4168 L
3778 4118 mt 3728 4168 L
7968 2957 mt 8018 3007 L
8018 2957 mt 7968 3007 L
gs 1209 428 7210 4654 rc
gr

3728 4626 mt 3778 4676 L
3778 4626 mt 3728 4676 L
7968 2923 mt 8018 2973 L
8018 2923 mt 7968 2973 L
gs 1209 428 7210 4654 rc
gr

3728 3980 mt 3778 4030 L
3778 3980 mt 3728 4030 L
7968 3079 mt 8018 3129 L
8018 3079 mt 7968 3129 L
gs 1209 428 7210 4654 rc
gr

3728 4135 mt 3778 4185 L
3778 4135 mt 3728 4185 L
7968 3740 mt 8018 3790 L
8018 3740 mt 7968 3790 L
gs 1209 428 7210 4654 rc
gr

3728 3876 mt 3778 3926 L
3778 3876 mt 3728 3926 L
7968 2678 mt 8018 2728 L
8018 2678 mt 7968 2728 L
gs 1209 428 7210 4654 rc
gr

3728 4709 mt 3778 4759 L
3778 4709 mt 3728 4759 L
7968 3134 mt 8018 3184 L
8018 3134 mt 7968 3184 L
gs 1209 428 7210 4654 rc
gr

3728 3755 mt 3778 3805 L
3778 3755 mt 3728 3805 L
7968 3433 mt 8018 3483 L
8018 3433 mt 7968 3483 L
gs 1209 428 7210 4654 rc
gr

3728 3492 mt 3778 3542 L
3778 3492 mt 3728 3542 L
7968 4016 mt 8018 4066 L
8018 4016 mt 7968 4066 L
gs 1209 428 7210 4654 rc
gr

24 W
c8
1633 4088 PD
24 W
1633 4147 PD
24 W
1633 4292 PD
24 W
1633 4053 PD
24 W
1633 3814 PD
gs 1209 428 7210 4654 rc
gr

c10
1608 4563 mt 1658 4613 L
1658 4563 mt 1608 4613 L
1608 4858 mt 1658 4908 L
1658 4858 mt 1608 4908 L
1608 4579 mt 1658 4629 L
1658 4579 mt 1608 4629 L
1608 4524 mt 1658 4574 L
1658 4524 mt 1608 4574 L
1608 4472 mt 1658 4522 L
1658 4472 mt 1608 4522 L
gs 1209 428 7210 4654 rc
gr

0 sg
3805 5530 mt 
(connection size \(MB\)) s
 711 3667 mt  -90 rotate
(completion time \(s\)) s
90 rotate
%%IncludeResource: font Helvetica
/Helvetica /ISOLatin1Encoding 120 FMSR

1192 5124 mt 
( ) s
8402  470 mt 
( ) s
1 sg
0 1172 1820 0 0 -1172 1504 1919 4 MP
PP
-1820 0 0 1172 1820 0 0 -1172 1504 1919 5 MP stroke
4 w
DO
SO
6 w
0 sg
1504 1919 mt 3324 1919 L
1504  747 mt 3324  747 L
1504 1919 mt 1504  747 L
3324 1919 mt 3324  747 L
1504 1919 mt 3324 1919 L
1504 1919 mt 1504  747 L
1504 1919 mt 3324 1919 L
1504  747 mt 3324  747 L
1504 1919 mt 1504  747 L
3324 1919 mt 3324  747 L
%%IncludeResource: font Helvetica
/Helvetica /ISOLatin1Encoding 216 FMSR

1991  986 mt 
(mean Cubic) s
gs 1504 747 1821 1173 rc
24 w
c8
375 0 1578 909 2 MP stroke
gr

24 w
c8
0 sg
1991 1269 mt 
(mean H-TCP) s
gs 1504 747 1821 1173 rc
DA
c9
375 0 1578 1191 2 MP stroke
SO
gr

c9
0 sg
1991 1552 mt 
(Cubic) s
gs 1504 747 1821 1173 rc
6 w
gs 1693 1401 147 147 rc
24 W
c8
1766 1474 PD
gr

c8
gr

6 w
c8
0 sg
1991 1835 mt 
(H-TCP) s
gs 1504 747 1821 1173 rc
gs 1693 1683 147 147 rc
24 W
c8
1766 1756 PD
gr

c8
gr

c8

end %%Color Dict

eplot
%%EndObject

epage
end

showpage

%%Trailer
%%EOF

--Boundary_(ID_/iyQX/nMHZHe8B6epBEGIg)
Content-type: application/postscript; x-unix-mode=0644; name=tina2.eps
Content-transfer-encoding: 7bit
Content-disposition: inline; filename=tina2.eps

%!PS-Adobe-3.0 EPSF-3.0
%%Creator: MATLAB, The Mathworks, Inc. Version 7.4.0.287 (R2007a). Operating System: Darwin 8.11.1 Darwin Kernel Version 8.11.1: Wed Oct 10 18:23:28 PDT 2007; root:xnu-792.25.20~1/RELEASE_I386 i386.
%%Title: /Users/douglasleith/Desktop/pfldnet2008/tina2.eps
%%CreationDate: 02/25/2008  21:04:42
%%DocumentNeededFonts: Helvetica
%%DocumentProcessColors: Cyan Magenta Yellow Black
%%LanguageLevel: 2
%%Pages: 1
%%BoundingBox:   -81   150   694   642
%%EndComments

%%BeginProlog
% MathWorks dictionary
/MathWorks 160 dict begin
% definition operators
/bdef {bind def} bind def
/ldef {load def} bind def
/xdef {exch def} bdef
/xstore {exch store} bdef
% operator abbreviations
/c  /clip ldef
/cc /concat ldef
/cp /closepath ldef
/gr /grestore ldef
/gs /gsave ldef
/mt /moveto ldef
/np /newpath ldef
/cm /currentmatrix ldef
/sm /setmatrix ldef
/rm /rmoveto ldef
/rl /rlineto ldef
/s {show newpath} bdef
/sc {setcmykcolor} bdef
/sr /setrgbcolor ldef
/sg /setgray ldef
/w /setlinewidth ldef
/j /setlinejoin ldef
/cap /setlinecap ldef
/rc {rectclip} bdef
/rf {rectfill} bdef
% page state control
/pgsv () def
/bpage {/pgsv save def} bdef
/epage {pgsv restore} bdef
/bplot /gsave ldef
/eplot {stroke grestore} bdef
% orientation switch
/portraitMode 0 def /landscapeMode 1 def /rotateMode 2 def
% coordinate system mappings
/dpi2point 0 def
% font control
/FontSize 0 def
/FMS {/FontSize xstore findfont [FontSize 0 0 FontSize neg 0 0]
  makefont setfont} bdef
/reencode {exch dup where {pop load} {pop StandardEncoding} ifelse
  exch dup 3 1 roll findfont dup length dict begin
  { 1 index /FID ne {def}{pop pop} ifelse } forall
  /Encoding exch def currentdict end definefont pop} bdef
/isroman {findfont /CharStrings get /Agrave known} bdef
/FMSR {3 1 roll 1 index dup isroman {reencode} {pop pop} ifelse
  exch FMS} bdef
/csm {1 dpi2point div -1 dpi2point div scale neg translate
 dup landscapeMode eq {pop -90 rotate}
  {rotateMode eq {90 rotate} if} ifelse} bdef
% line types: solid, dotted, dashed, dotdash
/SO { [] 0 setdash } bdef
/DO { [.5 dpi2point mul 4 dpi2point mul] 0 setdash } bdef
/DA { [6 dpi2point mul] 0 setdash } bdef
/DD { [.5 dpi2point mul 4 dpi2point mul 6 dpi2point mul 4
  dpi2point mul] 0 setdash } bdef
% macros for lines and objects
/L {lineto stroke} bdef
/MP {3 1 roll moveto 1 sub {rlineto} repeat} bdef
/AP {{rlineto} repeat} bdef
/PDlw -1 def
/W {/PDlw currentlinewidth def setlinewidth} def
/PP {closepath eofill} bdef
/DP {closepath stroke} bdef
/MR {4 -2 roll moveto dup  0 exch rlineto exch 0 rlineto
  neg 0 exch rlineto closepath} bdef
/FR {MR stroke} bdef
/PR {MR fill} bdef
/L1i {{currentfile picstr readhexstring pop} image} bdef
/tMatrix matrix def
/MakeOval {newpath tMatrix currentmatrix pop translate scale
0 0 1 0 360 arc tMatrix setmatrix} bdef
/FO {MakeOval stroke} bdef
/PO {MakeOval fill} bdef
/PD {currentlinewidth 2 div 0 360 arc fill
   PDlw -1 eq not {PDlw w /PDlw -1 def} if} def
/FA {newpath tMatrix currentmatrix pop translate scale
  0 0 1 5 -2 roll arc tMatrix setmatrix stroke} bdef
/PA {newpath tMatrix currentmatrix pop	translate 0 0 moveto scale
  0 0 1 5 -2 roll arc closepath tMatrix setmatrix fill} bdef
/FAn {newpath tMatrix currentmatrix pop translate scale
  0 0 1 5 -2 roll arcn tMatrix setmatrix stroke} bdef
/PAn {newpath tMatrix currentmatrix pop translate 0 0 moveto scale
  0 0 1 5 -2 roll arcn closepath tMatrix setmatrix fill} bdef
/vradius 0 def /hradius 0 def /lry 0 def
/lrx 0 def /uly 0 def /ulx 0 def /rad 0 def
/MRR {/vradius xdef /hradius xdef /lry xdef /lrx xdef /uly xdef
  /ulx xdef newpath tMatrix currentmatrix pop ulx hradius add uly
  vradius add translate hradius vradius scale 0 0 1 180 270 arc 
  tMatrix setmatrix lrx hradius sub uly vradius add translate
  hradius vradius scale 0 0 1 270 360 arc tMatrix setmatrix
  lrx hradius sub lry vradius sub translate hradius vradius scale
  0 0 1 0 90 arc tMatrix setmatrix ulx hradius add lry vradius sub
  translate hradius vradius scale 0 0 1 90 180 arc tMatrix setmatrix
  closepath} bdef
/FRR {MRR stroke } bdef
/PRR {MRR fill } bdef
/MlrRR {/lry xdef /lrx xdef /uly xdef /ulx xdef /rad lry uly sub 2 div def
  newpath tMatrix currentmatrix pop ulx rad add uly rad add translate
  rad rad scale 0 0 1 90 270 arc tMatrix setmatrix lrx rad sub lry rad
  sub translate rad rad scale 0 0 1 270 90 arc tMatrix setmatrix
  closepath} bdef
/FlrRR {MlrRR stroke } bdef
/PlrRR {MlrRR fill } bdef
/MtbRR {/lry xdef /lrx xdef /uly xdef /ulx xdef /rad lrx ulx sub 2 div def
  newpath tMatrix currentmatrix pop ulx rad add uly rad add translate
  rad rad scale 0 0 1 180 360 arc tMatrix setmatrix lrx rad sub lry rad
  sub translate rad rad scale 0 0 1 0 180 arc tMatrix setmatrix
  closepath} bdef
/FtbRR {MtbRR stroke } bdef
/PtbRR {MtbRR fill } bdef
/stri 6 array def /dtri 6 array def
/smat 6 array def /dmat 6 array def
/tmat1 6 array def /tmat2 6 array def /dif 3 array def
/asub {/ind2 exch def /ind1 exch def dup dup
  ind1 get exch ind2 get sub exch } bdef
/tri_to_matrix {
  2 0 asub 3 1 asub 4 0 asub 5 1 asub
  dup 0 get exch 1 get 7 -1 roll astore } bdef
/compute_transform {
  dmat dtri tri_to_matrix tmat1 invertmatrix 
  smat stri tri_to_matrix tmat2 concatmatrix } bdef
/ds {stri astore pop} bdef
/dt {dtri astore pop} bdef
/db {2 copy /cols xdef /rows xdef mul dup 3 mul string
  currentfile 
  3 index 0 eq {/ASCIIHexDecode filter}
  {/ASCII85Decode filter 3 index 2 eq {/RunLengthDecode filter} if }
  ifelse exch readstring pop
  dup 0 3 index getinterval /rbmap xdef
  dup 2 index dup getinterval /gbmap xdef
  1 index dup 2 mul exch getinterval /bbmap xdef pop pop}bdef
/it {gs np dtri aload pop moveto lineto lineto cp c
  cols rows 8 compute_transform 
  rbmap gbmap bbmap true 3 colorimage gr}bdef
/il {newpath moveto lineto stroke}bdef
currentdict end def
%%EndProlog

%%BeginSetup
MathWorks begin

0 cap

end
%%EndSetup

%%Page: 1 1
%%BeginPageSetup
%%PageBoundingBox:   -81   150   694   642
MathWorks begin
bpage
%%EndPageSetup

%%BeginObject: obj1
bplot

/dpi2point 12 def
portraitMode -0972 7704 csm

    0     0  9302  5894 rc
85 dict begin %Colortable dictionary
/c0 { 0.000000 0.000000 0.000000 sr} bdef
/c1 { 1.000000 1.000000 1.000000 sr} bdef
/c2 { 0.900000 0.000000 0.000000 sr} bdef
/c3 { 0.000000 0.820000 0.000000 sr} bdef
/c4 { 0.000000 0.000000 0.800000 sr} bdef
/c5 { 0.910000 0.820000 0.320000 sr} bdef
/c6 { 1.000000 0.260000 0.820000 sr} bdef
/c7 { 0.000000 0.820000 0.820000 sr} bdef
c0
1 j
1 sg
   0    0 9303 5895 rf
6 w
0 4804 7209 0 0 -4804 1209 5246 4 MP
PP
-7209 0 0 4804 7209 0 0 -4804 1209 5246 5 MP stroke
4 w
DO
SO
6 w
0 sg
1209 5246 mt 8418 5246 L
1209  442 mt 8418  442 L
1209 5246 mt 1209  442 L
8418 5246 mt 8418  442 L
1209 5246 mt 8418 5246 L
1209 5246 mt 1209  442 L
1209 5246 mt 1209 5173 L
1209  442 mt 1209  514 L
%%IncludeResource: font Helvetica
/Helvetica /ISOLatin1Encoding 216 FMSR

1149 5481 mt 
(0) s
1864 5246 mt 1864 5173 L
1864  442 mt 1864  514 L
1804 5481 mt 
(1) s
2519 5246 mt 2519 5173 L
2519  442 mt 2519  514 L
2459 5481 mt 
(2) s
3175 5246 mt 3175 5173 L
3175  442 mt 3175  514 L
3115 5481 mt 
(3) s
3830 5246 mt 3830 5173 L
3830  442 mt 3830  514 L
3770 5481 mt 
(4) s
4485 5246 mt 4485 5173 L
4485  442 mt 4485  514 L
4425 5481 mt 
(5) s
5141 5246 mt 5141 5173 L
5141  442 mt 5141  514 L
5081 5481 mt 
(6) s
5796 5246 mt 5796 5173 L
5796  442 mt 5796  514 L
5736 5481 mt 
(7) s
6451 5246 mt 6451 5173 L
6451  442 mt 6451  514 L
6391 5481 mt 
(8) s
7107 5246 mt 7107 5173 L
7107  442 mt 7107  514 L
7047 5481 mt 
(9) s
7762 5246 mt 7762 5173 L
7762  442 mt 7762  514 L
7642 5481 mt 
(10) s
8418 5246 mt 8418 5173 L
8418  442 mt 8418  514 L
8298 5481 mt 
(11) s
1209 5246 mt 1281 5246 L
8418 5246 mt 8345 5246 L
1054 5326 mt 
(0) s
1209 4765 mt 1281 4765 L
8418 4765 mt 8345 4765 L
 934 4845 mt 
(10) s
1209 4285 mt 1281 4285 L
8418 4285 mt 8345 4285 L
 934 4365 mt 
(20) s
1209 3804 mt 1281 3804 L
8418 3804 mt 8345 3804 L
 934 3884 mt 
(30) s
1209 3324 mt 1281 3324 L
8418 3324 mt 8345 3324 L
 934 3404 mt 
(40) s
1209 2844 mt 1281 2844 L
8418 2844 mt 8345 2844 L
 934 2924 mt 
(50) s
1209 2363 mt 1281 2363 L
8418 2363 mt 8345 2363 L
 934 2443 mt 
(60) s
1209 1883 mt 1281 1883 L
8418 1883 mt 8345 1883 L
 934 1963 mt 
(70) s
1209 1402 mt 1281 1402 L
8418 1402 mt 8345 1402 L
 934 1482 mt 
(80) s
1209  922 mt 1281  922 L
8418  922 mt 8345  922 L
 934 1002 mt 
(90) s
1209  442 mt 1281  442 L
8418  442 mt 8345  442 L
 814  522 mt 
(100) s
1209 5246 mt 8418 5246 L
1209  442 mt 8418  442 L
1209 5246 mt 1209  442 L
8418 5246 mt 8418  442 L
gs 1209 442 7210 4805 rc
24 w
/c8 { 0.000000 0.000000 1.000000 sr} bdef
c8
657 -272 3277 -1524 1966 -1107 655 -236 1864 4520 5 MP stroke
DA
/c9 { 0.000000 0.500000 0.000000 sr} bdef
c9
657 -249 3277 -1528 1966 -792 655 -258 1864 4781 5 MP stroke
SO
6 w
gr

c9
24 W
c8
1864 4641 PD
24 W
2519 4578 PD
24 W
4485 3243 PD
24 W
7762 863 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4414 PD
24 W
2519 4342 PD
24 W
4485 1843 PD
24 W
7762 971 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4560 PD
24 W
2519 4550 PD
24 W
4485 3513 PD
24 W
7762 2557 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4807 PD
24 W
2519 4121 PD
24 W
4485 2803 PD
24 W
7762 1556 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4193 PD
24 W
2519 4426 PD
24 W
4485 4608 PD
24 W
7762 1392 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4805 PD
24 W
2519 4778 PD
24 W
4485 3202 PD
24 W
7762 1609 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4591 PD
24 W
2519 4787 PD
24 W
4485 4153 PD
24 W
7762 1404 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4220 PD
24 W
2519 4203 PD
24 W
4485 3111 PD
24 W
7762 1904 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4845 PD
24 W
2519 4309 PD
24 W
4485 2692 PD
24 W
7762 1295 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4388 PD
24 W
2519 4039 PD
24 W
4485 3475 PD
24 W
7762 2093 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4546 PD
24 W
2519 4091 PD
24 W
4485 2509 PD
24 W
7762 1306 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4311 PD
24 W
2519 4709 PD
24 W
4485 2656 PD
24 W
7762 1049 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4357 PD
24 W
2519 4317 PD
24 W
4485 3310 PD
24 W
7762 2051 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 5070 PD
24 W
2519 3967 PD
24 W
4485 3171 PD
24 W
7762 1811 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4439 PD
24 W
2519 3913 PD
24 W
4485 3616 PD
24 W
7762 2022 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4666 PD
24 W
2519 3803 PD
24 W
4485 3323 PD
24 W
7762 2121 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4151 PD
24 W
2519 3263 PD
24 W
4485 3047 PD
24 W
7762 2029 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4462 PD
24 W
2519 4087 PD
24 W
4485 3001 PD
24 W
7762 1437 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4285 PD
24 W
2519 4264 PD
24 W
4485 3083 PD
24 W
7762 2720 PD
gs 1209 442 7210 4805 rc
gr

24 W
1864 4646 PD
24 W
2519 5124 PD
24 W
4485 3176 PD
24 W
7762 870 PD
gs 1209 442 7210 4805 rc
gr

/c10 { 1.000000 0.000000 0.000000 sr} bdef
c10
1839 4638 mt 1889 4688 L
1889 4638 mt 1839 4688 L
2494 4612 mt 2544 4662 L
2544 4612 mt 2494 4662 L
4460 3509 mt 4510 3559 L
4510 3509 mt 4460 3559 L
7737  777 mt 7787  827 L
7787  777 mt 7737  827 L
gs 1209 442 7210 4805 rc
gr

1839 4222 mt 1889 4272 L
1889 4222 mt 1839 4272 L
2494 4699 mt 2544 4749 L
2544 4699 mt 2494 4749 L
4460 2819 mt 4510 2869 L
4510 2819 mt 4460 2869 L
7737 1888 mt 7787 1938 L
7787 1888 mt 7737 1938 L
gs 1209 442 7210 4805 rc
gr

1839 4602 mt 1889 4652 L
1889 4602 mt 1839 4652 L
2494 4701 mt 2544 4751 L
2544 4701 mt 2494 4751 L
4460 3554 mt 4510 3604 L
4510 3554 mt 4460 3604 L
7737 3228 mt 7787 3278 L
7787 3228 mt 7737 3278 L
gs 1209 442 7210 4805 rc
gr

1839 4896 mt 1889 4946 L
1889 4896 mt 1839 4946 L
2494 4582 mt 2544 4632 L
2544 4582 mt 2494 4632 L
4460 3791 mt 4510 3841 L
4510 3791 mt 4460 3841 L
7737 2784 mt 7787 2834 L
7787 2784 mt 7737 2834 L
gs 1209 442 7210 4805 rc
gr

1839 4821 mt 1889 4871 L
1889 4821 mt 1839 4871 L
2494 4652 mt 2544 4702 L
2544 4652 mt 2494 4702 L
4460 4193 mt 4510 4243 L
4510 4193 mt 4460 4243 L
7737 1461 mt 7787 1511 L
7787 1461 mt 7737 1511 L
gs 1209 442 7210 4805 rc
gr

1839 4546 mt 1889 4596 L
1889 4546 mt 1839 4596 L
2494 4530 mt 2544 4580 L
2544 4530 mt 2494 4580 L
4460 3876 mt 4510 3926 L
4510 3876 mt 4460 3926 L
7737 1021 mt 7787 1071 L
7787 1021 mt 7737 1071 L
gs 1209 442 7210 4805 rc
gr

1839 4853 mt 1889 4903 L
1889 4853 mt 1839 4903 L
2494 4289 mt 2544 4339 L
2544 4289 mt 2494 4339 L
4460 2819 mt 4510 2869 L
4510 2819 mt 4460 2869 L
7737 2937 mt 7787 2987 L
7787 2937 mt 7737 2987 L
gs 1209 442 7210 4805 rc
gr

1839 4779 mt 1889 4829 L
1889 4779 mt 1839 4829 L
2494 3866 mt 2544 3916 L
2544 3866 mt 2494 3916 L
4460 4064 mt 4510 4114 L
4510 4064 mt 4460 4114 L
7737 2600 mt 7787 2650 L
7787 2600 mt 7737 2650 L
gs 1209 442 7210 4805 rc
gr

1839 4903 mt 1889 4953 L
1889 4903 mt 1839 4953 L
2494 4210 mt 2544 4260 L
2544 4210 mt 2494 4260 L
4460 3387 mt 4510 3437 L
4510 3387 mt 4460 3437 L
7737 2141 mt 7787 2191 L
7787 2141 mt 7737 2191 L
gs 1209 442 7210 4805 rc
gr

1839 4775 mt 1889 4825 L
1889 4775 mt 1839 4825 L
2494 4515 mt 2544 4565 L
2544 4515 mt 2494 4565 L
4460 3566 mt 4510 3616 L
4510 3566 mt 4460 3616 L
7737 2540 mt 7787 2590 L
7787 2540 mt 7737 2590 L
gs 1209 442 7210 4805 rc
gr

1839 4634 mt 1889 4684 L
1889 4634 mt 1839 4684 L
2494 4857 mt 2544 4907 L
2544 4857 mt 2494 4907 L
4460 3841 mt 4510 3891 L
4510 3841 mt 4460 3891 L
7737 3124 mt 7787 3174 L
7787 3124 mt 7737 3174 L
gs 1209 442 7210 4805 rc
gr

1839 5101 mt 1889 5151 L
1889 5101 mt 1839 5151 L
2494 3807 mt 2544 3857 L
2544 3807 mt 2494 3857 L
4460 3834 mt 4510 3884 L
4510 3834 mt 4460 3884 L
7737 2333 mt 7787 2383 L
7787 2333 mt 7737 2383 L
gs 1209 442 7210 4805 rc
gr

1839 4567 mt 1889 4617 L
1889 4567 mt 1839 4617 L
2494 4525 mt 2544 4575 L
2544 4525 mt 2494 4575 L
4460 4401 mt 4510 4451 L
4510 4401 mt 4460 4451 L
7737 1422 mt 7787 1472 L
7787 1422 mt 7737 1472 L
gs 1209 442 7210 4805 rc
gr

1839 4800 mt 1889 4850 L
1889 4800 mt 1839 4850 L
2494 4403 mt 2544 4453 L
2544 4403 mt 2494 4453 L
4460 4313 mt 4510 4363 L
4510 4313 mt 4460 4363 L
7737 2482 mt 7787 2532 L
7787 2482 mt 7737 2532 L
gs 1209 442 7210 4805 rc
gr

1839 4774 mt 1889 4824 L
1889 4774 mt 1839 4824 L
2494 4668 mt 2544 4718 L
2544 4668 mt 2494 4718 L
4460 3948 mt 4510 3998 L
4510 3948 mt 4460 3998 L
7737 2960 mt 7787 3010 L
7787 2960 mt 7737 3010 L
gs 1209 442 7210 4805 rc
gr

1839 5037 mt 1889 5087 L
1889 5037 mt 1839 5087 L
2494 4433 mt 2544 4483 L
2544 4433 mt 2494 4483 L
4460 3041 mt 4510 3091 L
4510 3041 mt 4460 3091 L
7737  933 mt 7787  983 L
7787  933 mt 7737  983 L
gs 1209 442 7210 4805 rc
gr

1839 4794 mt 1889 4844 L
1889 4794 mt 1839 4844 L
2494 4414 mt 2544 4464 L
2544 4414 mt 2494 4464 L
4460 3960 mt 4510 4010 L
4510 3960 mt 4460 4010 L
7737 2128 mt 7787 2178 L
7787 2128 mt 7737 2178 L
gs 1209 442 7210 4805 rc
gr

1839 4813 mt 1889 4863 L
1889 4813 mt 1839 4863 L
2494 4985 mt 2544 5035 L
2544 4985 mt 2494 5035 L
4460 3799 mt 4510 3849 L
4510 3799 mt 4460 3849 L
7737 2187 mt 7787 2237 L
7787 2187 mt 7737 2237 L
gs 1209 442 7210 4805 rc
gr

1839 4853 mt 1889 4903 L
1889 4853 mt 1839 4903 L
2494 4334 mt 2544 4384 L
2544 4334 mt 2494 4384 L
4460 4148 mt 4510 4198 L
4510 4148 mt 4460 4198 L
7737 2328 mt 7787 2378 L
7787 2328 mt 7737 2378 L
gs 1209 442 7210 4805 rc
gr

1839 4718 mt 1889 4768 L
1889 4718 mt 1839 4768 L
2494 4886 mt 2544 4936 L
2544 4886 mt 2494 4936 L
4460 3250 mt 4510 3300 L
4510 3250 mt 4460 3300 L
7737 2287 mt 7787 2337 L
7787 2287 mt 7737 2337 L
gs 1209 442 7210 4805 rc
gr

0 sg
3805 5695 mt 
(connection size \(MB\)) s
 711 3757 mt  -90 rotate
(completion time \(s\)) s
90 rotate
%%IncludeResource: font Helvetica
/Helvetica /ISOLatin1Encoding 120 FMSR

1192 5289 mt 
( ) s
8402  484 mt 
( ) s
1 sg
0 1172 1820 0 0 -1172 1516 1873 4 MP
PP
-1820 0 0 1172 1820 0 0 -1172 1516 1873 5 MP stroke
4 w
DO
SO
6 w
0 sg
1516 1873 mt 3336 1873 L
1516  701 mt 3336  701 L
1516 1873 mt 1516  701 L
3336 1873 mt 3336  701 L
1516 1873 mt 3336 1873 L
1516 1873 mt 1516  701 L
1516 1873 mt 3336 1873 L
1516  701 mt 3336  701 L
1516 1873 mt 1516  701 L
3336 1873 mt 3336  701 L
%%IncludeResource: font Helvetica
/Helvetica /ISOLatin1Encoding 216 FMSR

2003  940 mt 
(mean Cubic) s
gs 1516 701 1821 1173 rc
24 w
c8
375 0 1590 863 2 MP stroke
gr

24 w
c8
0 sg
2003 1223 mt 
(mean H-TCP) s
gs 1516 701 1821 1173 rc
DA
c9
375 0 1590 1145 2 MP stroke
SO
gr

c9
0 sg
2003 1506 mt 
(Cubic) s
gs 1516 701 1821 1173 rc
6 w
gs 1705 1355 147 147 rc
24 W
c8
1778 1428 PD
gr

c8
gr

6 w
c8
0 sg
2003 1789 mt 
(H-TCP) s
gs 1516 701 1821 1173 rc
gs 1705 1637 147 147 rc
24 W
c8
1778 1710 PD
gr

c8
gr

c8

end %%Color Dict

eplot
%%EndObject

epage
end

showpage

%%Trailer
%%EOF

--Boundary_(ID_/iyQX/nMHZHe8B6epBEGIg)
Content-type: text/plain; charset=US-ASCII; format=flowed
Content-transfer-encoding: 7BIT









--Boundary_(ID_/iyQX/nMHZHe8B6epBEGIg)--
