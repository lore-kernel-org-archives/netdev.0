From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC 1/2] labeled ipsec internet drafts
Date: Sat, 26 Jul 2008 12:34:43 -0400
Message-ID: <200807261234.44086.paul.moore@hp.com>
References: <200807251751.m6PHpJk4012058@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, gcwilson@us.ibm.com, serue@us.ibm.com,
	tjaeger@cse.psu.edu, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Joy Latten <latten@austin.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200807251751.m6PHpJk4012058@faith.austin.ibm.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 25 July 2008 1:51:19 pm Joy Latten wrote:
> I have attached two internet drafts for labeled ipsec for the
> community's review if interested.
>
> I have not yet submitted to IETF. I'd need comments by next
> Thursday (July 31) so I can incorporate any comments before
> submitting.

I'm CC'ing the LSM and netdev lists because there are some smart people 
there too that might want to comment on these proposed specifications.  
Otherwise my comments are below.

> There are two drafts because IKEv1 was obsoleted by IKEv2, but most
> are still using IKEv1. I also noticed some recent IPsec rfcs,
> particularly those proposing algorithm suites sometimes referred to
> IKEv1 also, although it has been obsoleted. So just in case, there is
> a draft for IKEv1 too. It didn't seem the drafts could be merged
> since ikev1 and ikev2 are different.
>
> Lastly, IPsec architecture rfc 2401 was obsoleted by rfc 4301.
> 2401, section 8 supported "MLS networking" within IPsec. All this was
> removed from rfc 4301. Thus the labeled ipsec draft for ikev2,
> reintroduces mls networking as MAC Networking and is longer.
>
> Please let me know if anything is missing or could be improved.
> Thanks!
>
> regards,
> Joy
>
> ---------------------------------------------------------------
>
>
>
>
>
> Network Working Group                                   J. Latten
> Internet-Draft                                          G. Wilson
> Intended Status: Standards Track                        S. Hallyn
> Expires: ?                                                    IBM
>                                                         T. Jaeger
>                                                        Penn State
>                                                         June 2008
>
>                         Security Label Addendum to
>                     IPsec Domain of Interpretation (DOI)
>                       for Internet Security Association
>                     and Key Management Protocol (ISAKMP)
>
>                   draft-jml-ipsec-ikev1-security-label-00
>
> Status of This Memo
>
>    By submitting this Internet-Draft, each author represents that any
>    applicable patent or other IPR claims of which he or she is aware
>    have been or will be disclosed, and any of which he or she becomes
>    aware will be disclosed, in accordance with Section 6 of BCP 79.
>
>    Internet-Drafts are working documents of the Internet Engineering
>    Task Force (IETF), its areas, and its working groups. Note that
>    other groups may also distribute working documents as Internet-
>    Drafts.
>
>    Internet-Drafts are draft documents valid for a maximum of six
> months and may be updated, replaced, or obsoleted by other documents
> at any time. It is inappropriate to use Internet-Drafts as reference
> material or to cite them other than as "work in progress".
>
>    The list of current Internet-Drafts can be accessed at
>    http://www.ietf.org/ietf/1id-abstracts.txt.
>
>    The list of Internet-Draft Shadow Directories can be accessed at
>    http://www.ietf.org/shadow.html.
>
>    This Internet-Draft will expire on December, 2008.
>
> Copyright Notice
>
>    Copyright (C) The IETF Trust (2008)
>
> Abstract
>
>    This document describes the need for and the use of a security
> label within IPsec. It describes the extension to the Internet IP
> Security
>
>
>
> Latten, et al.               Expires ?                          [Page
> 1] 
> Internet-Draft               IKEv1SecurityLabel                June
> 2008
>
>
>    Domain of Interpretation (IPsec DOI) [RFC2407] for the Internet
>    Security Association and Key Management Protocol (ISAKMP)
> [RFC2408]. This extension supports the negotiation of the security
> label for a particular IP Authentication Header (AH) [RFC4302] or IP
>    Encapsulating Security Payload (ESP) [RFC4303] security
> association.
>
> 1. Introduction
>
>    Traditionally, security context referred to the security level and

Should this be "security label" instead of "security context"?

>    category used by Multilevel Security (MLS). This document will

This should probably bet "category set" or something similar.

> refer to the security level and category as the security
> classification.

Do you mean "MLS security classification"?  That "MLS" qualifier helps 
make it a bit more concrete and appears to match how you actually use 
it in the document.

>
>    Current security mechanisms, such as SELinux, use the security
>    classification and additional security attributes to form their
>    security context. For example, a type for type enforcement.
>
>    Techniques such as IP Security Options (IPSO) allow IP datagrams
> to be labeled with an MLS security classification [RFC1108]. This
> ensured the same security applied to local objects and resources was
> utilized when communicating over the network with homogenous systems.

I think you should either remove the "homogeneous" qualifier or change 
it to heterogeneous.  We've seen both different MLS implementations as 
well as MLS/Type-Enforcement implementations interoperate using IP 
options; granted it was with CIPSO and not RFC1108 but they are similar 
enough for this level of discussion.

> However, these techniques cannot pass along the additional security
> attributes used in current security mechanisms.

This is an intersting point and the following argument may be a bit 
contentious, but arguably you could encode random security contexts 
into a traditional MLS security context; Smack is a shining example of 
this as it encodes the generic Smack label into a CIPSO permissive 
bitmap tag.  It may violate the spirit of the CIPSO specification but 
it is valid and provides a strong counterexample.

Further, the FIPS-188 specification, while not an IETF specification, 
does provide for a "freeform" IP option which is intended to support 
arbitrary security attributes.

>    The ISAKMP specification defines a Situation field in the Security
>    Association payload [RFC2408]. The IPsec DOI describes the use of
>    this field to communicate sensitivity and integrity classification
>    information between initiator and responder when negotiating a
>    security association [RFC2407]. However, it does not provide for
>    additional security attributes that may be required by the
> security mechanism being deployed in the environment.
>
>    This document describes the additions to the IPsec DOI for ISAKMP
>    that are needed to support communication of additional security
>    attributes between two hosts, in particular a security label.
>
> 2. Terminology
>
>    The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
> NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in
> this document are to be interpreted as described in [RFC2119].
>
>
>
>
>
>
>
>
>
>
>
> Latten, et al.               Expires ?                          [Page
> 2] 
> Internet-Draft               IKEv1SecurityLabel                June
> 2008
>
>
> 3. IPsec Security Association Attribute
>
>     The following SA attribute definition is used in Phase II of an
>     Internet Key Exchange Protocol (IKE) negotiation that includes a
>     security label. The attribute type is Variable-Length (V).
>     Encoding of attributes is defined in the base ISAKMP
> specification [RFC2408].
>
>     Attribute Type
>
>                 class                   value           type
>           ------------------------------------------------------
>                Security Label             ?              V
>
>     Class Values
>
>       Security Label
>
>         Specifies that the security association is being negotiated
>         in an environment that requires labeled security. This field
>         will contain the security label.
>         The security label has the following format.
>
>         0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
> 1 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>
>        |     doi       |  algorithm    |            length           
>        |  |
>
>       
> +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>
>        |                 security label (variable)                   
>        |  |
>
>       
> +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>
>                      Figure 1: Security Label format
>
>        - doi (1 octet) - The first octet contains the security
> label's domain of interpretation.
>
>          The domain of interpretation can be viewed as a group of
>          systems that agree on the meaning of particular values
> within the security label of a security mechanism.
>
>          The value of 1 is reserved as the default.
>
>          Reserved       0
>          Default        1
>
>        - algorithm (1 octet) - The second octet contains the security
>          label's algorithm.
>
>
>
>
> Latten, et al.               Expires ?                          [Page
> 3] 
> Internet-Draft               IKEv1SecurityLabel                June
> 2008
>
>
>          The security label's algorithm specifies the security
>          mechanism or context in which the label is applicable. For
>          example, the security label is interpreted within the
> SELinux context.
>
>          Requests for assignment of additional algorithms should be
>          addressed to the Internet Assigned Numbers Authority (IANA).
>
>          Reserved       0
>          SELinux        1
>          Smack          2
>          Private Use    120-128

Is one octet enough here?  I honestly don't have a good idea as to how 
much is enough, so a little justification of your choice (even if it 
only lives in email, not in the spec) would be welcome.

I'm also concerned with the implied convention of assigning one value to 
a particular implementation.  In the SELinux case, how do you deal with 
a non-MLS/MCS policy such as Gentoo/Ubuntu talking to a MLS/MCS policy 
such as Fedora/RHEL?  What about policies with different types?  
Differing numbers of MLS sensitivity levels or categories?

Also, can you explain the reason for having both a DOI and a algorithm 
field?  From an interoperability point of view, the node's security 
implementation is irrelevant as long as it agrees to abide by the rules 
and labels specified in the DOI.  I understand that currently a SELinux 
security label looks different from a traditional MLS/CMW security 
label, but there is no reason that a translation mechanism could not be 
implemented to provide a common network security label that could be 
understood and internalized by both types of systems.  While I'm not 
holding this up as a particularly good example in all cases, we do have 
something similar to this today in SELinux with how we handle the CIPSO 
protocol.

>        - length (2 octets) - The third and fourth octets contain the
>          string length of the security context.
>
>        - security label (1 or more octets) - The security label. The
>          actual content will be dependent on the security algorithm
>          that is specified. Within IKE context, this is regarded as
>          an opaque bit string.

I'm being picky here, but it might be better to say "opaque bit field" 
just so we don't get into string encoding issues (is it UTF-8 or 
something else?).

> 3. Attribute Negotiation
>
>    If an implementation receives an IPsec DOI attribute or attribute
>    value that it does not support, it SHOULD send an
>    ATTRIBUTES-NOT-SUPPORT and the security association negotiation
>    and setup MUST be aborted.

See my comments in the next email about needing more text around how 
security enforcement must be handled by the different implementations.

> 4. Security Considerations
>
>    This document describes an extension to IKE [RFC2409] and ISAKMP
>    [RFC2408] protocols. The use of the described security label
> should not change the basic security features of the two.
>
>    The IPsec DOI describes a Situation field whose values can be
>    SIT_SECRECY and/or SIT_INTEGRITY. When SIT_SECRECY is used, it
>    indicates an environment requiring labeled secrecy and is
>    followed with sensitivity label. When SIT_INTEGITY is used,
>    it indicates an environment requiring labeled integrity and
>    is followed with integrity information.
>
>    SIT_SECRECY and SIT_INTEGRITY themselves indicate the use of
>    a security label and therefore the security attribute described
>    in this document MUST NOT be used in conjunction with either.
>    The new security attribute extends the existing security
>    mechanism to allow for additional interpretations of a security
>    label and not just those defined by SIT_SECRECY and SIT INTEGRITY.
>    It is possible that the sensitivity level and/or integrity level
> are
>
>
>
> Latten, et al.               Expires ?                          [Page
> 4] 
> Internet-Draft               IKEv1SecurityLabel                June
> 2008
>
>
>    included in the security label defined by the security algorithm
>    using the new security attribute.
>
> 5. IANA Considerations
>
>    This document contains two new "magic numbers" which are allocated
>    and maintained by IANA registry.
>
>         - The class value for the security label attribute.
>
>                   class            value     type
>               -----------------------------------------
>                 Security Label       ?        V
>
>           Only one value assigned by IANA is required.
>
>           - The value for the security algorithm.
>
>                 SELinux         1(?)
>                 Smack           2(?)
>
>           Additional values may be assigned by IANA for the
>           security mechanisms requiring IKE to communicate its
>           security label.
>
> Acknowledgements
>
>    The authors would like to thank Stephen Smalley, James Morris and
>    the SELinux community for their work on labeled ipsec.
>
> Normative References
>
>    [RFC2119]    Bradner, S., "Key words for use in RFCs to Indicate
>                 Requirement Level", BCP 14, RFC 2119, March 1997.
>
>    [RFC2407]    Piper, D., "The Internet IP Security Domain of
>                 Interpretation for ISAKMP", RFC 2407, November 1998.
>
>    [RFC2408]    Maughan, D., Schertler, M., Schneider, M., and
>                 J. Turner, "Internet Security Association and Key
>                 Management Protocol", RFC 2408, November 1998.
>
>    [RFC2409]    Harkins, D. and D. Carrel, "The Internet Key
> Exchange", RFC 2409, November 1998.
>
>    [RFC4302]   Kent, S., "IP Authentication Header", RFC 4302,
>                December 2005.
>
>
>
>
> Latten, et al.               Expires ?                          [Page
> 5] 
> Internet-Draft               IKEv1SecurityLabel                June
> 2008
>
>
>    [RFC4303]   Kent, S., "IP Encapsulating Security Payload (ESP)",
>                RFC 4303, December 2005.
>
> Informative references
>
>    [RFC1108]   Kent, S., "U.S. DoD Security Options for the Internet
>                Protocol, RFC 1108, November 1991.
>
> Authors' Addresses
>
> Joy Latten
> IBM
> email: latten@austin.ibm.com
>
> George Wilson
> IBM
> email: gcwilson@us.ibm.com
>
> Serge Hallyn
> IBM
> email: serue@us.ibm.com
>
> Trent Jaeger
> Penn State
> email: tjaeger@cse.psu.edu
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
>
> Latten, et al.               Expires ?                          [Page
> 6] 
> Internet-Draft               IKEv1SecurityLabel                June
> 2008
>
>
> Full Copyright Statement
>
>    Copyright (C) The IETF Trust (2008).
>
>    This document is subject to the rights, licenses and restrictions
>    contained in BCP 78, and except as set forth therein, the authors
>    retain all their rights.
>
>    This document and the information contained herein are provided on
> an "AS IS" basis and THE CONTRIBUTOR, THE ORGANIZATION HE/SHE
> REPRESENTS OR IS SPONSORED BY (IF ANY), THE INTERNET SOCIETY, THE
> IETF TRUST AND THE INTERNET ENGINEERING TASK FORCE DISCLAIM ALL
> WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY
> WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE ANY
> RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
> PARTICULAR PURPOSE.
>
> Intellectual Property
>
>    The IETF takes no position regarding the validity or scope of any
>    Intellectual Property Rights or other rights that might be claimed
>    to pertain to the implementation or use of the technology
>    described in this document or the extent to which any license
>    under such rights might or might not be available; nor does it
>    represent that it has made any independent effort to identify any
>    such rights.  Information on the procedures with respect to rights
>    in RFC documents can be found in BCP 78 and BCP 79.
>
>    Copies of IPR disclosures made to the IETF Secretariat and any
>    assurances of licenses to be made available, or the result of an
>    attempt made to obtain a general license or permission for the use
>    of such proprietary rights by implementers or users of this
>    specification can be obtained from the IETF on-line IPR repository
>    at http://www.ietf.org/ipr.
>
>    The IETF invites any interested party to bring to its attention
>    any copyrights, patents or patent applications, or other
>    proprietary rights that may cover technology that may be required
>    to implement this standard.  Please address the information to the
>    IETF at ietf-ipr@ietf.org.
>
>
>
>
>
>
>
>
>
>
>
>
> Latten, et al.               Expires ?                          [Page
> 7] 

-- 
paul moore
linux @ hp
